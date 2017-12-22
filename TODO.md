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
    [x] `Edm.GeographyPoint`
    [ ] `Edm.GeographyMultiPoint`
    [x] `Edm.GeographyLineString`
    [ ] `Edm.GeographyMultiLineString`
    [x] `Edm.GeographyPolygon` (see note below)
        [ ] Support for holes
        [ ] Support for other serialization formats
    [ ] `Edm.GeopgrahyMultiPolygon`

##### NOTE

Due to the lack of library support for GeoXML/GML in Ruby, Geography support is somewhat limited. For instance, [there are more than 3 different ways to represent a polygon in GML][gml-madness], all of which are equivalent and interchangeable. However, due to the lack of GML libraries, we currently only support a single serialization format (`<gml:LinearRing>` with `<gml:pos>` elements, see [polygon_spec.rb][polygon_spec]).

[gml-madness]: http://erouault.blogspot.com/2014/04/gml-madness.html
[polygon_spec]: spec/odata/v4/properties/geography/polygon_spec.rb

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
  [x] Date/time functions
  [x] Geospatial functions
  [x] [Lambda operators][1]

[ ] Logging

[1]: http://docs.oasis-open.org/odata/odata/v4.0/errata02/os/complete/part2-url-conventions/odata-v4.0-errata02-os-part2-url-conventions-complete.html#_Toc406398149

## Questions / Thoughts

[ ] Use standard JSON parser or OJ (or offer choice?)
[x] Continue to support XML data format (JSON is recommended for V4)? -> We'll support both, ATOM first, JSON to be added later.
