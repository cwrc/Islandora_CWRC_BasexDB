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
  (: based on orlando_bibl_to_mods.xsl in cwrc_migration_batch transforms :)
  let $regex_mla_date := "((\d{1,2}\s)?(January|February|March|April|May|June|July|August|September|October|November|December|Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s\d{4})"
  let $regex_year := "\d{4}"
  let $regex_month_list := "(January|February|March|April|May|June|July|August|September|October|November|December|Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)"
  let $bibl_list := /BIBLIOGRAPHY_ENTRY[RESPONSIBILITY[@WORKSTATUS="PUB" and @WORKVALUE="C"]]


  
  
  (: 
  let $bibl_list := /obj[@pid/data()='orlando:5d31c2bc-9f4b-474f-bd6b-0de76d8f3586'] 
  :)

  return
    <checks type="array">
    {
      for $bibl at $pos in $bibl_list
        let $id := $bibl/@BI_ID/data()
        let $tag_list := $bibl//(DATE_OF_PUBLICATION)[@NO_DATE='0']/DATE
          [not(matches(text(),"^\d{4}-?\d{0,2}-?\d{0,2}$"))]
          [not(matches(text(),"^\d{4}-(\d{4})?$"))][not(matches(text(),"^((\d{1,2}\s)?(January|February|March|April|May|June|July|August|September|October|November|December|Jan|Feb|Mar|Apr|May|Jun|Jul|Aug|Sep|Oct|Nov|Dec)\s\d{4})$"))]
          [not(matches(text(),"^(Spring|Summer|Fall|Autumn|Winter)\s\d{4}$"))]
          [not(matches(text(),concat('^',$regex_mla_date, '\s?-', '(\s?', $regex_mla_date, ')?$')))]
          [not(matches(text(),concat('^\d{1,2}-\d{1,2}',' ', $regex_month_list, ' ', $regex_year, '$')))]
        
        (:
          [not(ancestor::RESPONSIBILITY)][not(matches(text(),"^(\d{4}(-\d{0,2}(-\d{0,2})?)?)$|^((\d{1,2}\s)?(January|February|March|April|May|June|July|August|September|October|November|December)\s\d{4})$"))]
:)
        
        return
          
          for $item in $tag_list
            let $item_text := $item/text()
            let $item_attr := $item/@VALUE/data()
            return 
              <_ type="object">
                  <log>[{$id}] element with text [{$item_text}]</log>
                </_>
      }
      </checks>
    }
    </json>