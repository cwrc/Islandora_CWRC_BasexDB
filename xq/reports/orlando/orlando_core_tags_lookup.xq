(: 
*
* Test core tags within documents  - biography/writing/events 
*
*
* View linked person/org within documents  - biography/writing/events
* and report on whether or not the linking is working (e.g., name/@ref
* to an entity item) and the workflow status of the bibliography item
* (e.g., PUB-C or not).
* 
* replace the Orlando Doc Archive Core Tag Lookup Report
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
      <strong class="pub_c">{$entity/@label/data()} - id:{$ref_id} - PUB-C {local:entityHref($entity/@pid/data())}</strong>
    else if ( $workflow/activity[@stamp="orlando:CAS"] and $workflow/activity[@status="c"] ) then
      <em class="cas_c">{$entity/@label/data()} - id:{$ref_id} - CAS-C {local:entityHref($entity/@pid/data())}</em>
    else if ( $workflow ) then
      <d class="non_pub_c"><strong>No PUB-C/CAS-C</strong> - {$entity/@label/data()} - id:{$ref_id} {local:entityHref($entity/@pid/data())}</d>
    else if ( $entity ) then
      <d class="warning">{$ref_id} no responsibility found {local:entityHref($entity/@pid/data())}</d>
    else if ( $ref_id ) then
      <d class="error">{$ref_id} - no matching object found </d>
    else
      <d class="error">REF attribute missing</d>
  )
};


declare function local:entityHref($id)
{
  <span>
    <a href="{$BASE_URL}/{$id}" target="_blank">view</a>
    <a href="{$BASE_URL}/{$id}/datastream/MODS/edit" target="_blank">edit</a>
    <a href="{$BASE_URL}/{$id}/workflow" target="_blank">add workflow</a>
  </span>
};

(: convert to Orlando standard name :)

declare function local:convertStandardName($str)
{
  if (contains($str, ' ')) then
    let $tok := tokenize($str, ' ')
    return (: handle multiple space e.g. Ernest Thompson Seton :)
      fn:concat($tok[last()], ', ', fn:string-join($tok[position()!=last()], ' '))
  else
    $str
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
      (: find the core tag elements (not in responsibility statements :)
      for $item in $accessible_seq/CWRC_DS//(NAME|ORGNAME|PLACE|TITLE)[not(parent::RESPONSIBILITY)]
      let $group_by_id := $item/@REF/data()
      group by $group_by_id
      order by $group_by_id 
      return
        <div>
        {
          (: output details of the referenced entry :)
          let $entity := cwAccessibility:queryAccessControl(/)[@uri/data()=$group_by_id]
          return local:outputEntityDetails($group_by_id, $entity)
        }
        <ul>
        {
          (: output placeholder and tag text of bibcit or textscope :)
          for $a in $accessible_seq//(NAME|ORGNAME|PLACE|TITLE)[
            (@REF = $group_by_id) or (fn:empty($group_by_id) and not(@REF))
            ]
          let $str := fn:string-join($a/text())
          let $elm := $a/name()
          let $ref := $a/@REF/data()
          let $alt := $a/@STANDARD/data()
          group by $elm, $str, $ref, $alt
          order by $elm, $str, $ref, $alt
          return
            <li>[{$elm}] REF:[{$ref}] - STANDARD:[{$alt}] - Text:[{$str}]</li>

        }
        </ul>
      </div>
    }
    </div>
  </div>


