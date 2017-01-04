(:
* test all bibcit/textscope element in all objects with a given collection
* report only the elements with warnings or errors
*
:)

xquery version "3.0" encoding "utf-8";

import module namespace cwAccessibility="cwAccessibility" at "./islandora_access_control.xq";

declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace fedora =  "info:fedora/fedora-system:def/relations-external#";
declare namespace fedora-model="info:fedora/fedora-system:def/model#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";


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


declare function local:outputBiblDetails($ref_id, $bibl, $accessible_seq)
{
  let $workflow := $bibl/WORKFLOW_DS/cwrc/workflow
  return
  (
    if ( $workflow/activity[@stamp="orlando:PUB" and @status="c"] ) then
      <strong class="pub_c">PUB-C - {$bibl/@label/data()} {local:bibcitHref($bibl/@pid/data())}</strong>
    else if ( $workflow/activity[@stamp="orlando:CAS" and @status="c"] ) then
      <em class="cas_c">CAS-C without PUB-C - {$bibl/@label/data()} {local:bibcitHref($bibl/@pid/data())}</em>
    else if ( $workflow ) then
      <d class="non_pub_c"><strong>No PUB-C/CAS-C Workflow</strong> - {$bibl/@label/data()} {local:bibcitHref($bibl/@pid/data())}</d>
    else if ( $bibl ) then
      <d class="warning">no responsibility found - {$bibl/@label/data()} {local:bibcitHref($bibl/@pid/data())}</d>
    else if ( $ref_id ) then
      <d class="error">no matching bibliography item found [{$ref_id}]
      { local:listObjectContaining($ref_id, $accessible_seq) }
      </d>
    else
      <d class="error">REF attribute missing 
      { local:listObjectContaining($ref_id, $accessible_seq) }
      </d>
  )
};

declare function local:listObjectContaining($id, $accessible_seq)
{
  for $i in $accessible_seq[CWRC_DS//(BIBCIT|TEXTSCOPE)[@REF = $id or not(exists(@REF))]]
  let $doc_href := fn:concat($BASE_URL,'/',$accessible_seq/@pid/data())
  let $doc_label := fn:string-join( ($accessible_seq/@label/data(),  $accessible_seq/@pid/data()), ' - ')
  order by $doc_label 
  return 
    <li><a href="{$doc_href}">{$doc_label}</a></li>
};

declare function local:bibcitHref($id)
{
  <span>
    <a title="{$id}" href="{$BASE_URL}/{$id}" target="_blank">view</a>
    <a title="{$id}" href="{$BASE_URL}/{$id}/datastream/MODS/edit" target="_blank">edit</a>
    <a title="{$id}" href="{$BASE_URL}/{$id}/workflow" target="_blank">add workflow</a>
  </span>
};


(: the main section: :)

(: get all members of a collection :)
let $id := fn:string-join(("info:fedora/",$FEDORA_PID),'')
let $accessible_seq := cwAccessibility:queryAccessControl(/)[@pid=$FEDORA_PID or RELS-EXT_DS/rdf:RDF/rdf:Description/fedora:isMemberOfCollection/@rdf:resource=$id]

return
<div>
  {
  for $item in $accessible_seq/CWRC_DS//(BIBCIT|TEXTSCOPE)
  let $group_by_id := $item/@REF/data() 
  (: only bibl items that are not pub-c :)
  let $bibl := cwAccessibility:queryAccessControl(/)[@uri/data()=$group_by_id][not((WORKFLOW_DS/cwrc/workflow/activity[@stamp="orlando:PUB" and @status="c"])[1])]  
(:
  let $bibl := cwAccessibility:queryAccessControl(/)[@uri/data()=$group_by_id]
:)
  where exists($bibl) or not(exists($group_by_id))
  group by $group_by_id
  return
    <div>
      { 
      local:outputBiblDetails($group_by_id, $bibl, $accessible_seq) 
      }
    </div>
  }
</div>


