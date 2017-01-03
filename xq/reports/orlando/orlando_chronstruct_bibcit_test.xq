(: 
*
* test chronstruct contains bibcit - biography/writing/events - check bibcit 
*
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
        (: test for chronstructs containing bibcits and output :)
        (: look in both biography and writing and event in different paths :)
        let $set := $accessible_seq/CWRC_DS/child::*[not(name()='EVENT')]/(descendant::CHRONSTRUCT[not(descendant::BIBCIT)] | EVENT/CHRONEVENT[not(descendant::BIBCIT)]/CHRONSTRUCT ) 
        let $is_citations := $accessible_seq/CWRC_DS/(descendant::BIBCIT)[1] 
        return
          if ( fn:count($set) > 0 )
          then
            for $item in $set 
            return
              <li class="error">{fn:string-join($item, ' ')}</li>
          else if ( fn:count($is_citations) = 0 )
          then
            <li class="error">No citations found.</li>
          else
            <li>Each chronstruct element contains at least one bibcit element.</li>
      }
      </ul>
    </div>
  </div>


