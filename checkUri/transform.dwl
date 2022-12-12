%dw 2.0
import * from dw::core::Strings
/*
var client_id=vars.client_ID_expression
var requestUri=attributes.requestUri
var requestUriTrimmed=substringBefore(requestUri,"?")
var method=attributes.method
var clientIDsSet=namesOf(vars.clientIDMapSet)
var clientIDCheck= if(clientIDsSet contains(client_id)) true else false
var clientIDSelected=if(clientIDCheck) vars.clientIDMapSet."$(client_id)" else "{}"
var paths = clientIDSelected."paths"

*/
var requestUri="0/plpl?"
var requestUriTrimmed=if(sizeOf(substringBefore(requestUri,"?"))==0) requestUri else substringBefore(requestUri,"?")
var method="GET"
var paths = payload."paths"

// Get the namesOf All paths
var namesOfPaths = namesOf(paths)
// Check for Paths either that they are empty or allow all paths
var pathAllnEmptyCheck = !((namesOf(paths) contains "*") or isEmpty(paths))
// Map Build for Pattren Matching
var pathCheck = paths mapObject ((value, key, index) -> 
  (key): value.values distinctBy ($) map ((item, index) -> key replace ("{" ++ substringBefore(substringAfter(key, "{"), "}") ++ "}") with item)
)
// Regex Matching Builder
var pathsRegex = (namesOfPaths map ((item, index) -> ({
  (item replace ("{" ++ substringBefore(substringAfter(item, "{"), "}") ++ "}") with ".*"): item
}))) reduce ((item, accumulator = {}) -> accumulator ++ item)
// Remove any "*" entrys
var setValues = namesOf(pathsRegex) - "*"
// Get matched pattern from available paths
var namesMatcher = setValues reduce ((item, accumulator = setValues) -> if (isEmpty(requestUriTrimmed match (item as String)))
    accumulator - item
  else
    accumulator)
// Get Matched path from pattern
var pathCheckSelect = if (pathAllnEmptyCheck)
  if (!isEmpty(namesMatcher))
    pathsRegex."$(namesMatcher[0])"
  else
    // 
    null
else
  false
var valuesArray = if (!isEmpty(namesMatcher))
  pathCheck."$(pathCheckSelect)"
else
  []
// Check for Available values check
var pathValuesCheck = if (!isEmpty(pathCheckSelect) and pathAllnEmptyCheck)
  (if (paths."$(pathCheckSelect)".values contains "*")
    "PASS_ALL_VALUES"
  else if (isEmpty((valuesArray reduce ((item, accumulator = valuesArray) -> if (isEmpty(requestUriTrimmed match (item as String)))
      accumulator - item
    else
      accumulator))))
    "ERROR"
  else
    "CHECK_METHOD")
else if (pathCheckSelect == null)
  "NOMATCHING"
else
  "PASS_ALL_PATHS"
// Check for VALUES
var pathCheckingValues = if (pathValuesCheck == "PASS_ALL_VALUES")
  (if (paths."$(pathCheckSelect)".method contains "*")
    "PASS_ALL_METHODS"
  else
    "CHECK_METHODS")
else if (pathValuesCheck == "NOMATCHING")
  "DO_NOTHING"
else if (pathValuesCheck == "CHECK_METHOD" and !(paths."$(pathCheckSelect)".method contains "*"))
  "CHECK_METHODS"
else if (pathValuesCheck == "ERROR")
  "RAISE_VALUE_ERROR"
else
  "DO_NOTHING"

// Value array 
var methodValuesArray = if (!isEmpty(namesMatcher))
  (paths."$(pathCheckSelect)".method default []) - "*"
else
  []
// Checking for Methods
var pathCheckingMethods = if (pathCheckingValues == "PASS_ALL_METHODS" or pathCheckingValues == "DO_NOTHING")
  "DO_NOTHING"
else if (pathCheckingValues == "CHECK_METHODS")
  if (isEmpty((methodValuesArray reduce ((item, accumulator = methodValuesArray) -> if (isEmpty(method match (item as String)))
      accumulator - item
    else
      accumulator))))
    "RAISE_METHOD_ERROR"
  else
    "DO_NOTHING"
else if (pathCheckingValues == "RAISE_VALUE_ERROR")
  "RAISE_VALUE_ERROR"
else
  "DO_NOTHING"

output application/json  
---
/*
{
    pathCheck: {pathCheckValue:if(pathCheckingMethods=="RAISE_VALUE_ERROR") true else false,pathCheckString:"PathID/Value Dosen't Match"},
    methodCheck:{methodCheckValue: if(pathCheckingMethods=="RAISE_METHOD_ERROR") true else false,methodCheckString:"MethodCheck Doesn't Match"}*/
test:requestUriTrimmed
