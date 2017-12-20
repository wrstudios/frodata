# OData V4 To-Do

This is a non-complete list of things that need to be done in order to achieve OData V4 compatibility. It will be updated regularly to keep track with current development.

## Tasks

[x] `DataServiceVersion` headers changes to `OData-Version`
[x] Atom: update namespace URIs
[x] Implement JSON data format
  [x] with batch processing
[ ] Implement missing/new OData V4 types
  [x] `Edm.Date` (V4/RESO)
  [ ] `Edm.Duration` (V4)
  [x] `Edm.TimeOfDay` (V4/RESO)
  [x] `Edm.EnumType` (V4/RESO)
  [ ] `Edm.Geography` subtypes (RESO)
    [ ] `Edm.GeographyPoint`
    [ ] `Edm.GeographyMultiPoint`
    [ ] `Edm.GeographyLineString`
    [ ] `Edm.GeographyMultiLineString`
    [ ] `Edm.GeographyPolygon`
    [ ] `Edm.GeopgrahyMultiPolygon`

[ ] Changes to `NavigationProperty`
  [x] No more associations (but we probably still need a proxy class)
  [x] New `Type` property
  [x] New `Nullable` property
  [x] New `Partner` property
  [ ] New `ContainsTarget` property

[ ] Changes to querying
  [x] `$count=true` replaces `$inlinecount=allpages`
  [x] New `$search` param for fulltext search
  [x] String functions
  [ ] [Lambda operators][1]

[ ] Logging

[1]: http://docs.oasis-open.org/odata/odata/v4.0/errata02/os/complete/part2-url-conventions/odata-v4.0-errata02-os-part2-url-conventions-complete.html#_Toc406398149

## Questions / Thoughts

[ ] Use standard JSON parser or OJ (or offer choice?)
[x] Continue to support XML data format (JSON is recommended for V4)? -> We'll support both, ATOM first, JSON to be added later.
