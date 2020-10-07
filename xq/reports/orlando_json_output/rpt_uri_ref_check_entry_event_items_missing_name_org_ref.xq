(:
*
* Check the uri's present in the entry for corresponding target
* Returns a JSON response
*
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


<json type="object">
{

  let $entry_list := /obj[RELS-EXT_DS/rdf:RDF/rdf:Description/fedora:isMemberOfCollection/@rdf:resource/data()=("info:fedora/orlando:c5f53703-1f08-4c72-9425-2874bb7cf544","info:fedora/orlando:e6b8f85f-5a79-4124-b2a2-3b41c3ddb2cf") ][CWRC_DS/(ENTRY|EVENT)]
  (: let $entry_list := /obj[@pid/data()='orlando:laurma'] :)

  return
    for $entry in $entry_list
      let $ds := $entry/CWRC_DS/(ENTRY|EVENT)
      let $doc_id := $entry/@pid/data()
      let $doc_label := $ds/ORLANDOHEADER/FILEDESC/TITLESTMT/DOCTITLE/text()
      let $tag_list := $ds//(NAME|ORGNAME)
      order by $doc_id
    
      return
            for $item in $tag_list
            let $item_label := $item/(@STANDARD/data())
            let $item_text := $item/text()
            let $element_name := $item/name()
            return
              if ( not($item/@REF) ) then
              <_ type="object">
                <id>{$doc_id}</id>
                <log>"No REF attribute found" in [{$element_name}] element with STANDARD attribute [{$item_label}] and text [{$item_text}]</log>
              </_>
                
       
}    
</json>