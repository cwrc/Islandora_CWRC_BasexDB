(: 
*
* quotes within documents - biography/writing/events - check bibcit 
*
* find the quote elements and output - don't check nested QUOTE elements 
*
:)


xquery version "3.0" encoding "utf-8";

import module namespace cwAccessibility="cwAccessibility" at "./islandora_access_control.xq";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "xml";
declare option output:encoding "UTF-8";
declare option output:indent   "no";


declare variable $FEDORA_PID external := "";
declare variable $BASE_URL external := "";



(: the main section: :)
let $accessible_seq := cwAccessibility:queryAccessControl(/)[@pid=$FEDORA_PID]
let $doc_href := fn:concat($BASE_URL,'/',$accessible_seq/@pid/data())
let $doc_label := fn:string-join( ($accessible_seq/@label/data(),  $accessible_seq/@pid/data()), ' - ')
return
  <div>
    <h2 class="xquery_result">
      <a href="{$doc_href}">{$doc_label}</a>
    </h2>
    <div class="xquery_result_list">
      <ul>
      {
        (: find the quote elements and output - don't check nested QUOTE elements  :)
        let $set := $accessible_seq/CWRC_DS//QUOTE
        return
          if ( count($set) > 0 )
          then
            for $item in $set 
            let $bibcit_sibling := $item/following-sibling::BIBCITS/BIBCIT
            return
              if ( $bibcit_sibling ) 
              then
                <li><strong>{$item}</strong>
                <table>
                {
                  for $a in $bibcit_sibling 
                  return 
                      <tr>
                        <td>Placeholder:[{$a/@PLACEHOLDER/data()}]</td>
                        <td>Text:[{$a/text()}]</td>
                      <!-- DBREF:[{$a/@DBREF/data()}] - QTDIN:[{$a/@QTDIN/data()}] - -->
                      </tr>
                }
                </table>
                </li>
              else if ($item[ancestor::QUOTE])
                then
                <li><strong class="warning">{$item}</strong><div>Quote is nested within a quote - no bibcit test.</div></li>
              else
                <li><strong class="error">{$item}</strong></li>
          else
            <li><strong>No quote elements found.</strong></li>
      }
      </ul>
    </div>
  </div>


