(:
* 
* Check the uri's present in the bibliographic item for corresponding target
* Returns a JSON response
:)


xquery version "3.0" encoding "utf-8";

declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace dc = "http://purl.org/dc/elements/1.1/";
declare namespace fedora="info:fedora/fedora-system:def/relations-external#";
declare namespace fedora-model="info:fedora/fedora-system:def/model#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";

declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "json";
declare option output:encoding "UTF-8";
declare option output:indent   "yes";

declare variable $BASE_URL external := "https://commons.cwrc.ca/";


<json type="object">

{

let $bibl_list := /obj[RELS-EXT_DS/rdf:RDF/rdf:Description/fedora:isMemberOfCollection/@rdf:resource/data()=("info:fedora/orlando:f1caf219-2d9a-4662-b52c-d40ab08fbf3f") ]
(: 
let $bibl_list := /obj[@pid/data()='orlando:5d31c2bc-9f4b-474f-bd6b-0de76d8f3586'] 
:)


return
  for $bibl in $bibl_list
    let $ds := $bibl/MODS_DS/mods:modsCollection
    let $doc_id := $bibl/@pid/data()
    let $doc_label := $bibl/@label/data()
    let $entity_id_list := distinct-values($ds//(mods:name|mods:publisher)/@valueURI/data())
    order by $doc_id
  
    return
      <item type="object">
        { (: output details of the doc :) }
        <id>{$doc_id}</id>
        <label>{$doc_label}</label>
        <entityDetails type="array">
        {
          for $entity_id in $entity_id_list
          order by $entity_id
          return
            <_ type="object">
              <entityId>{$entity_id}</entityId>
              {
                let $target_pid := substring-after($entity_id,'https://commons.cwrc.ca/')
                let $target := /obj[@pid/data()=$target_pid]
                let $target_label := $target/@label/data()
                let $workflow := $target/WORKFLOW_DS/cwrc/workflow
                let $status :=
                  if ($workflow/activity[@stamp="orlando:PUB"] and $workflow/activity[@status="c"] ) then
                      "PUB-C"
                    else if ( $target ) then
                      "WARNING"
                    else 
                     "ERROR"
                let $log :=
                  if ( not($target) ) then
                    "No linked bibliography item found"
                  else if ( not($workflow) ) then
                    "No responsibility statements found"
                  else 
                    ()
                return
                  (
                    <linkedObject type="object">
                      <targetPid>{$target_pid}</targetPid>
                      <targetLabel>{$target_label}</targetLabel>
                      <status>{$status}</status>
                      <log>{$log}</log>
                    </linkedObject>
                  )
              }
            </_>
              
        }
        </entityDetails>
        
      </item>
}    
</json>