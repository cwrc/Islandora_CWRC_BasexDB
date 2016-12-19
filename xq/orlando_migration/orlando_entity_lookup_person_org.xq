(:
* 
* Orlando migration process: lookup a person/org object pid 
* to help add URIs to Orlando biography/writing/event document 
* name/orgname/standard elements
*
* Given a lookup string, return an identifier for a person/organization entity
*
:)

xquery version "3.0" encoding "utf-8";

(: don't use the cwAcccessiblity access control :)

(: declare namespaces used in the content :)
declare namespace mods = "http://www.loc.gov/mods/v3";
declare namespace tei =  "http://www.tei-c.org/ns/1.0";
declare namespace fedora =  "info:fedora/fedora-system:def/relations-external#";
declare namespace fedora-model="info:fedora/fedora-system:def/model#";
declare namespace rdf="http://www.w3.org/1999/02/22-rdf-syntax-ns#";


(: options :)
declare namespace output = "http://www.w3.org/2010/xslt-xquery-serialization";
declare option output:method "json";
declare option output:encoding "UTF-8";
declare option output:indent   "no";

(: external variables :)
declare variable $LOOKUP_STR external := "";
declare variable $CMODEL_STR external := "";

(: the main section: :)
(:
:)
let $pid_list := (/obj[
  RELS-EXT_DS/rdf:RDF/rdf:Description/fedora-model:hasModel/@rdf:resource/data()=$CMODEL_STR
  and
  (PERSON_DS|ORGANIZATION_DS)/entity/(organization|person)/identity/variantForms/variant[variantType="orlandoStandardName" and authorizedBy/projectId="orlando"]/namePart/text() = $LOOKUP_STR
  ])/@pid/data()

return
  json:serialize(
    <json type='object' objects='pids'>
    <pids type='array'>
    {
      for $pid in $pid_list
      return
        <_>{$pid}</_>
    }
    </pids>
    </json>
  )
