import element.{type Element}
import node_list.{type NodeList}

@external(javascript, "./document_ffi.mjs", "get_element_by_id")
pub fn get_element_by_id(id: String) -> Element

@external(javascript, "./document_ffi.mjs", "query_selector")
pub fn query_selector(selector: String) -> Element

@external(javascript, "./document_ffi.mjs", "query_selector_all")
pub fn query_selector_all(selector: String) -> NodeList(Element)
