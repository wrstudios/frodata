# OData V4 To-Do

This is a non-complete list of things that need to be done in order to achieve OData V4 compatibility. It will be updated regularly to keep track with current development.

## Tasks

[x] `DataServiceVersion` headers changes to `OData-Version`
[x] Atom: update namespace URIs
[ ] Implement JSON data format
[ ] Implement missing/new OData V4 types
  [x] `Edm.Date` (V4/RESO)
  [ ] `Edm.Duration` (V4)
  [x] `Edm.TimeOfDay` (V4/RESO)
  [ ] `Edm.Geography` subtypes (RESO)
    [ ] `Edm.GeographyLineString`
    [ ] `Edm.GeographyPolygon`
    [ ] `Edm.GeographyMultiPoint`
    [ ] `Edm.GeographyMultiLineString`
    [ ] `Edm.GeopgrahyMultiPolygon`
  [ ] `Edm.EnumType` (V4/RESO)

[ ] Changes to `NavigationProperty`
  [x] No more associations (but we probably still need a proxy class)
  [ ] New `Type` property
  [ ] New `Nullable` property
  [ ] New `Partner` property
  [ ] New `ContainsTarget` property

[ ] Changes to querying
  [ ] ~`$count=true` replaces `$inlinecount=allpages`~
  [ ] ~New `$search` param for fulltext search (not needed for RESO)~

[ ] Logging


## Questions / Thoughts

[ ] Use standard JSON parser or OJ (or offer choice?)
[x] Continue to support XML data format (JSON is recommended for V4)? -> We'll support both, ATOM first, JSON to be added later.
