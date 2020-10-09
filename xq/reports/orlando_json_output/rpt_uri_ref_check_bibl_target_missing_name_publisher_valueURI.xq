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

<json type="object">
{

  let $bibl_list := /obj[RELS-EXT_DS/rdf:RDF/rdf:Description/fedora:isMemberOfCollection/@rdf:resource/data()=("info:fedora/orlando:7397f8b2-10d9-48b6-8af5-6c2cd24f50b5")][MODS_DS/mods:modsCollection//(mods:name|mods:publisher)[not(@valueURI)]]
  (: 
  let $bibl_list := /obj[@pid/data()='orlando:5d31c2bc-9f4b-474f-bd6b-0de76d8f3586'] 
  :)

  return
    <checks type="array">
    {
      for $bibl in $bibl_list
        let $ds := $bibl/MODS_DS/mods:modsCollection
        let $doc_id := $bibl/@pid/data()
        (: let $doc_label := $bibl/@label/data() :)
        let $tag_list := $ds//(mods:name|mods:publisher)
        order by $doc_id
      
        return
          for $item in $tag_list
            (: let $item_id := $item/(@valueURI/data()) :)
            let $item_text := normalize-space(string-join($item//text()))
            let $element_name := $item/name()
            return
              if ( not($item/@valueURI) ) then
                <_ type="object">
                  <id>{$doc_id}</id>
                  <log>No valueURI attribute found: [{$element_name}] element with text [{$item_text}]</log>
                </_>
              else
                ()
     }
     </checks>
}    
</json>