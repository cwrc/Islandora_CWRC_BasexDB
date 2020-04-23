(: 
*
* View cititations within documents  - biography/writing/events 
* Replaces the Orlando Doc Archive Bibcit Lookup Report 
* Returns a JSON response:
*
*
* 
*
:)


xquery version "3.0" encoding "utf-8";

import module namespace cwAccessibility="cwAccessibility" at "./islandora_access_control.xq";

declare namespace mods = "http://www.loc.gov/mods/v3";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "xml";
declare option output:encoding "UTF-8";
declare option output:indent   "no";


declare variable $FEDORA_PID external := "";
declare variable $BASE_URL external := "";

(:
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
(: find the bibcit reference and combine duplicates :)
(: ToDo: 2015-07-21 - switch to only @REF when feasible :)
(: use @REF or legacy @DBREF for the time being :)
let $bibcit_id_list := distinct-values($accessible_seq/CWRC_DS//(BIBCIT|TEXTSCOPE)/(@REF|@DBREF)/data())

return
  <item type="object">
    <id>{$doc_href}</id>
    <label>{$doc_label}</label>
    <details type="array" object="_">
    {
      for $group_by_id in $bibcit_id_list 
      order by $group_by_id
      return
        <_>
          <linked_bibl_status type="object">
          {
          (: output details of the reference bibliography entry :) 
          (: ToDo: 2015-07-21 - switch to only @pid when feasible :)
          let $bibl := cwAccessibility:queryAccessControl(/)[@pid/data()=$group_by_id or MODS_DS/mods:mods/mods:recordInfo/mods:recordIdentifier[@source="Orlando"]/text()=$group_by_id]
          let $workflow := $bibl/WORKFLOW_DS/cwrc/workflow
          return
          (
            <linked_id>{$group_by_id}</linked_id>
            <status></status>
            <log></log>
            (: RESPONSIBILITY[@WORKSTATUS="PUB"] and RESPONSIBILITY[@WORKVALUE="C"]  :)
            if ( $workflow/activity[@stamp="orl:PUB"] and $workflow/activity[@status="c"] ) then
              <link_label>{$bibl/@label/data()</link_label>
              <status>PUB-C</status>
              <log></log>
            else if ( $workflow/activity[@stamp="orl:CAS"] and $workflow/activity[@status="c"] ) then
              <link_label>{$bibl/@label/data()</link_label>
              <status>CAS-C</status>
              <log></log>
            else if ( $workflow ) then
              <link_label>{$bibl/@label/data()</link_label>
              <status>No PUB-C/CAS-C</status>
              <log></log>
            else if ( $bibl ) then
              <status>WARNING</status>
              <log>No responsibility statements found</log>
            else
              <status>ERROR</status>
              <log>No linked bibliography item found</log>
            )
          }
          </linked_bibl_status>
          <local_references type=array>
            {
            (: output placeholder and tag text of bibcit or textscope :)
            for $a in $accessible_seq//(TEXTSCOPE|BIBCIT)[@DBREF = $group_by_id]
            order by $a/@PLACEHOLDER/data()
            return
              <_>
                <ref>{$a/@DBREF/data()}</ref>
                <qtdin>{$a/@QTDIN/data()}</qtdin>
                <placeholder>{$a/@PLACEHOLDER/data()}</placeholder>
                <text>{$a/text()}</text>
              </_>
            }
          </local_references>
        </_>
    }
    </details>
  </item>


