(: 
*
* test chronstruct contains bibcit - biography/writing/events - check bibcit 
*
*
:)


xquery version "3.0" encoding "utf-8";

import module namespace cwAccessibility="cwAccessibility" at "../../islandora_access_control.xq";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "json";
declare option output:encoding "UTF-8";
declare option output:indent   "no";


declare variable $FEDORA_PID external := "";
declare variable $BASE_URL external := "";


(: test local content :)
(:
let $accessible_seq := /WRITING 
let $doc_id := $accessible_seq//STANDARD/text()
let $doc_label := $doc_id 
:)

(: the main section: :)
let $accessible_seq := cwAccessibility:queryAccessControl(/)[@pid=$FEDORA_PID]
let $doc_id := fn:concat($BASE_URL,'/',$accessible_seq/@pid/data())
let $doc_label := fn:string-join( ($accessible_seq/@label/data(),  $accessible_seq/@pid/data()), ' - ')

return 
  <json type="object">
    { (: output details of the doc :) }
    <id>{$doc_id}</id>
    <label>{$doc_label}</label>
    { (: output details of the report :) }
    <resultsList type="array">
      {
        (: find the researchnote elements and output  :)
        for $item at $pos in ($accessible_seq//CHRONSTRUCT)
        let $bibcit_descendant := $item/descendant::BIBCIT
        let $status_map := 
          if ( not($bibcit_descendant) ) then
            map { "status": "ERROR", "log": "No BIBCIT found in CHRONSTRUCT: " || $item}
          else 
            map { "status": "SUCCESS", "log": "position: " || $pos}

        return
          <_ type="object">
            <status>{$status_map('status')}</status>
            <log>{$status_map('log')}</log>
          </_>
      }
    </resultsList>
  </json>
