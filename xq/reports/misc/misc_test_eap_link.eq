(:
*
* Test the MODS datastream mod:subject linkage to a person entity
* and therefore the viability of the connection to an Entity Aggregation
* Page
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
* helper functions
:)


(:
* given a uri an XML node, report on the different properties
:)
declare function local:outputEntityDetails($ref_id, $entity)
{
  let $workflow := $entity/WORKFLOW_DS/cwrc/workflow
  return
  (
    if ( $workflow/activity[@stamp="orlando:PUB"] and $workflow/activity[@status="c"] ) then
      <strong class="pub_c">{$entity/@label/data()} - PUB-C {local:entityHref($entity/@pid/data())}</strong>
    else if ( $workflow/activity[@stamp="orlando:CAS"] and $workflow/activity[@status="c"] ) then
      <em class="cas_c">{$entity/@label/data()} - CAS-C {local:entityHref($entity/@pid/data())}</em>
    else if ( $workflow ) then
      <d class="non_pub_c">{$entity/@label/data()} - <strong>No PUB-C/CAS-C</strong> {local:entityHref($entity/@pid/data())}</d>
    else if ( $entity ) then
      <d class="warning">no responsibility found - {$entity/@label/data()} {local:entityHref($entity/@pid/data())}</d>
    else if ( $ref_id ) then
      <d class="error">no matching entity found [{$ref_id}]</d>
    else
      <d class="error">REF attribute missing</d>
  )
};

declare function local:entityHref($id)
{
  <span>
    <a title="{$id}" href="{$BASE_URL}/{$id}" target="_blank">view</a>
    <a title="{$id}" href="{$BASE_URL}/{$id}/datastream/MODS/edit" target="_blank">edit</a>
    <a title="{$id}" href="{$BASE_URL}/{$id}/workflow" target="_blank">add workflow</a>
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
      <!-- <span>Report details of bibcit/textscope elements and their linkage.</span> -->
    </h2>
    <div class="xquery_result_list">
    <ul>
    {
      for $item in $accessible_seq/MODS_DS/mods:mods/mods:subject/mods:name/@valueURI
      return
        <li>
        {
          (: output details of the referenced entry :)
          let $ref_id := $item/data() 
          let $entity := cwAccessibility:queryAccessControl(/)[@uri/data()=$ref_id]
          return local:outputEntityDetails($ref_id, $entity)
        }

            
        </li>
    }
    </ul>
    </div>
  </div>
