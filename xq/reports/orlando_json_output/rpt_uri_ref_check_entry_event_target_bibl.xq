(:
* 
* Check the uri's present in the entry for corresponding target
* Returns a JSON response
:)
xquery version "3.0" encoding "utf-8";

(:
module namespace cwRpt = "cwReport";
:)

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

declare function local:get_pid_from_uri($uri as xs:string) as xs:string
{
  substring-after($uri, $BASE_URL)
};


<json type="object">
{

  let $entry_list := /obj[RELS-EXT_DS/rdf:RDF/rdf:Description/fedora:isMemberOfCollection/@rdf:resource/data()=("info:fedora/orlando:c5f53703-1f08-4c72-9425-2874bb7cf544","info:fedora/orlando:e6b8f85f-5a79-4124-b2a2-3b41c3ddb2cf") ][CWRC_DS/(ENTRY|EVENT)]
  (: let $entry_list := /obj[@pid/data()='orlando:laurma'] :)

  return
    for $entry in $entry_list
      let $ds := $entry/CWRC_DS/(ENTRY|EVENT)
      let $doc_id := $entry/@pid/data()
      let $doc_label := $ds/ORLANDOHEADER/FILEDESC/TITLESTMT/DOCTITLE/text()
      let $bibl_id_list := distinct-values($ds//(BIBCIT|TEXTSCOPE)/@REF/data())
      order by $doc_id
    
      return
        <item type="object">
          { (: output details of the doc :) }
          <id>{$doc_id}</id>
          <label>{$doc_label}</label>
          <biblDetails type="array">
          {
            for $bibl_id in $bibl_id_list
            order by $bibl_id
            return
              <_ type="object">
                <biblId>{$bibl_id}</biblId>
                {
                  let $target_pid := local:get_pid_from_uri($bibl_id)
                  let $target := /obj[@pid/data()=$target_pid]
                  let $target_label := $target/@label/data()
                  let $workflow := $target/WORKFLOW_DS/cwrc/workflow
                  let $status :=
                    if ($workflow/activity[@stamp="orlando:PUB"] and $workflow/activity[@status="c"] ) then
                        "PUB-C"
                      else if ( $workflow/activity[@stamp="orlando:CAS"] and $workflow/activity[@status="c"] ) then 
                        "CAS-C"
                      else if ( $workflow ) then
                        "No PUB-C/CAS-C"
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
                      <linkedBiblObject type="object">
                        <targetPid>{$target_pid}</targetPid>
                        <targetLabel>{$target_label}</targetLabel>
                        <status>{$status}</status>
                        <log>{$log}</log>
                      </linkedBiblObject>
                    )
                }
              </_>
                
          }
          </biblDetails>
          
        </item>
}    
</json>