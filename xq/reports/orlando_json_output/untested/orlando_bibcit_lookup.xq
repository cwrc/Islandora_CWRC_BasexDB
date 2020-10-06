(: 
*
* View cititations within documents  - biography/writing/events 
* Replaces the Orlando Doc Archive Bibcit Lookup Report 
* Returns a JSON response:

{
  "id":"PID",
  "label":"Laurence, Margaret",
  "details":[
    {
      "biblID":"12265",
      "linkedBiblObject":{
        "status":"ERROR",
        "log":"No linked bibliography item found"
      },
      "localReferences":[
        {
          "placeholder":"IMDb",
          "ref":"",
          "dbref":"12265",
          "qtdin":"",
          "text":""
        }
      ]
    },
*
:)


xquery version "3.0" encoding "utf-8";

import module namespace cwAccessibility="cwAccessibility" at "../../islandora_access_control.xq";

declare namespace mods = "http://www.loc.gov/mods/v3";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "json";
declare option output:encoding "UTF-8";
declare option output:indent   "yes";


declare variable $FEDORA_PID external := "";
declare variable $BASE_URL external := "";

(:
:)

(: Settings to test with local files :)
(:
let $accessible_seq := /WRITING[1] 
let $doc_id := fn:concat($BASE_URL,'/',$accessible_seq//STANDARD/text())
let $doc_label := $accessible_seq//STANDARD/text()
let $bibcit_id_list := distinct-values($accessible_seq//(BIBCIT|TEXTSCOPE)/(@REF|@DBREF)/data())
:)

(: the main section: :)
let $accessible_seq := cwAccessibility:queryAccessControl(/)[@pid=$FEDORA_PID] 
let $doc_id := fn:concat($BASE_URL,'/',$accessible_seq/@pid/data())
let $doc_label := fn:string-join( ($accessible_seq/@label/data(),  $accessible_seq/@pid/data()), ' - ')
(: find the bibcit reference and combine duplicates :)
(: ToDo: 2015-07-21 - switch to only @REF when feasible :)
(: use @REF or legacy @DBREF for the time being :)
let $bibcit_id_list := distinct-values($accessible_seq/CWRC_DS//(BIBCIT|TEXTSCOPE)/(@REF|@DBREF)/data())

return
  <json type="object">
    { (: output details of the doc :) }
    <id>{$doc_id}</id>
    <label>{$doc_label}</label>
    { (: output details of the report :) }
    <details type="array">
    {
      (: for each citation in the source doc :)
      for $group_by_id in $bibcit_id_list 
      order by $group_by_id
      return
          <_ type="object">

          { (: output the id of the citation :) }
          <biblID>{$group_by_id}</biblID>
          
          { (: output the status of the link bibliography :) }
          {
            let $bibl := cwAccessibility:queryAccessControl(/)[@pid/data()=$group_by_id or MODS_DS/mods:mods/mods:recordInfo/mods:recordIdentifier[@source="Orlando"]/text()=$group_by_id]
            let $workflow := $bibl/WORKFLOW_DS/cwrc/workflow
            let $status :=
              if ($workflow/activity[@stamp="orl:PUB"] and $workflow/activity[@status="c"] ) then
                "PUB-C"
               else if ( $workflow/activity[@stamp="orl:CAS"] and $workflow/activity[@status="c"] ) then 
               "CAS-C"
               else if ( $workflow ) then
               "No PUB-C/CAS-C"
               else if ( $bibl ) then
               "WARNING"
              else 
               "ERROR"
            let $log :=
              if ( not($bibl) ) then
                "No linked bibliography item found"
              else if ( not($workflow) ) then
                "No responsibility statements found"
              else 
                ()
            return
            (
              <linkedBiblObject type="object">
                <status>{$status}</status>
                <log>{$log}</log>
              </linkedBiblObject>
            )
          }

          { (: output details of the document citation for checking :) }
          <localReferences type="array">
          { 
           for $a in $accessible_seq//(TEXTSCOPE|BIBCIT)[@DBREF = $group_by_id or @REF = $group_by_id]
            order by $a/@PLACEHOLDER/data()
            return
              <_ type="object">
              <placeholder>{$a/@PLACEHOLDER/data()}</placeholder>
              <ref>{$a/@REF/data()}</ref>
              <dbref>{$a/@DBREF/data()}</dbref>
              <qtdin>{$a/@QTDIN/data()}</qtdin>
              <text>{$a/text()}</text>
              </_>
          }
          </localReferences>

          </_>

    }
    </details>
  </json>


