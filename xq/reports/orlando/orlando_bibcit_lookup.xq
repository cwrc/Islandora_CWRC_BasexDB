(: 
*
* View cititations within documents  - biography/writing/events 
* and report on whether or not the linking is working (e.g., bibcit/@ref
* to a bibligraphy item) and the workflow status of the bibliography item
* (e.g., PUB-C or not).
*
* replace the Orlando Doc Archive Bibcit Lookup Report 
* use "@REF" URI's instead of "@DBREF" attributes for linking
*
* Input:
*   PID of a Fedora object
*
* output
*   HTML in the form of a report
*
*   Details about a bibliographic item
*     detail about each citation within the specifed document.
*     detail about each citation within the specifed document.
*     detail about each citation within the specifed document.
*     ...
*
*   Details about a bibliographic item
*     ...
*
:)


xquery version "3.0" encoding "utf-8";

import module namespace cwAccessibility="cwAccessibility" at "./islandora_access_control.xq";

declare namespace mods = "http://www.loc.gov/mods/v3";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "xml";
declare option output:encoding "UTF-8";
declare option output:indent   "no";


declare variable $FEDORA_PID external := "orlando:9f0c5add-7167-41bd-8111-77e0cff09ed5";
declare variable $BASE_URL external := "";

(:
* helper functions
:)

declare function local:bibcitHref($id)
{
  <span>
    <a href="{$BASE_URL}/{$id}" target="_blank">view</a>
    <a href="{$BASE_URL}/{$id}/datastream/MODS/edit" target="_blank">edit</a>
    <a href="{$BASE_URL}/{$id}/workflow" target="_blank">add workflow</a>
  </span>
};


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
    {
      (: find the bibcit and textscope bibl references (combine duplicates) :)
      for $group_by_id in distinct-values($accessible_seq/CWRC_DS//(BIBCIT|TEXTSCOPE)/@REF/data())
      order by $group_by_id
      return
        <div>
        <ul>
        {
        (: output details of the referenced bibliography entry :) 
        (: ToDo: 2015-07-21 - switch to only @pid when feasible :)
        let $bibl := cwAccessibility:queryAccessControl(/)[@pid/data()=$group_by_id]
        let $workflow := $bibl/WORKFLOW_DS/cwrc/workflow
        return
        (
          if ( $workflow/activity[@stamp="orlando:PUB"] and $workflow/activity[@status="c"] ) then
            <strong class="pub_c">{$bibl/@label/data()} - id:{$group_by_id} - PUB-C {local:bibcitHref($bibl/@pid/data())}</strong>
          else if ( $workflow/activity[@stamp="orlando:CAS"] and $workflow/activity[@status="c"] ) then
            <em class="cas_c">{$bibl/@label/data()} - id:{$group_by_id} - CAS-C {local:bibcitHref($bibl/@pid/data())}</em>
          else if ( $workflow ) then
            <d class="non_pub_c"><strong>No PUB-C/CAS-C</strong> - {$bibl/@label/data()} - id:{$group_by_id} {local:bibcitHref($bibl/@pid/data())}</d>
          else if ( $bibl ) then
            <d class="warning">{$group_by_id} no responsibility found {local:bibcitHref($bibl/@pid/data())}</d>
          else
            <d class="error">{$group_by_id} - no matching bibliography item found </d>
          )
        }
          <ul>
          {
          (: output placeholder and tag text of ibbcit or textscope :)
          for $a in $accessible_seq//(TEXTSCOPE|BIBCIT)[@REF = $group_by_id]
          order by $a/@PLACEHOLDER/data()
          return
            <li>REF:[{$a/@REF/data()}] - QTDIN:[{$a/@QTDIN/data()}] - Placeholder:[{$a/@PLACEHOLDER/data()}] - Text:[{$a/text()}]</li>
          }
          </ul>
        </ul>
        <ul>
          <d class="error">no matching bibliography item found </d>
          <ul>
          {
          for $a in $accessible_seq/CWRC_DS//(BIBCIT|TEXTSCOPE)[not(@REF)]
          return
            <li>REF:[{$a/@REF/data()}] - QTDIN:[{$a/@QTDIN/data()}] - Placeholder:[{$a/@PLACEHOLDER/data()}] - Text:[{$a/text()}]</li>
          }
          </ul>
        </ul>
      </div>
    }
    </div>
  </div>


