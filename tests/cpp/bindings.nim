type
  Color* {.importcpp:"math::Color", header:"test_cpp.hpp".} = enum
    Red = 0,
    Green = 1,
    Blue = 2
  Vec2*[T] {.importcpp:"math::Vec2", header:"test_cpp.hpp".} = object
    x* :T
    y* :T
  Vec3* {.importcpp:"math::Vec3", header:"test_cpp.hpp".} = object
    x* :cfloat
    y* :cfloat
    z* :cfloat
proc Vec3_create*() :Vec3 {.importcpp:"math::Vec3(@)", constructor, header:"test_cpp.hpp".}
proc Vec3_create*(x :cfloat; y :cfloat; z :cfloat) :Vec3 {.importcpp:"math::Vec3(@)", constructor, header:"test_cpp.hpp".}
proc destroy*(this :var Vec3) {.importcpp:"#.~Vec3()", header:"test_cpp.hpp".}
proc length*(this :Vec3) :cfloat {.importcpp:"#.length(@)", header:"test_cpp.hpp".}
proc normalize*(this :var Vec3) {.importcpp:"#.normalize(@)", header:"test_cpp.hpp".}
proc `+`*(this :Vec3; other :Vec3) :Vec3 {.importcpp:"# + #", header:"test_cpp.hpp".}
proc `-`*(this :Vec3; other :Vec3) :Vec3 {.importcpp:"# - #", header:"test_cpp.hpp".}
proc `*`*(this :Vec3; scalar :cfloat) :Vec3 {.importcpp:"# * #", header:"test_cpp.hpp".}
proc `-`*(this :Vec3) :Vec3 {.importcpp:"-#", header:"test_cpp.hpp".}
proc `==`*(this :Vec3; other :Vec3) :bool {.importcpp:"# == #", header:"test_cpp.hpp".}
proc `!=`*(this :Vec3; other :Vec3) :bool {.importcpp:"# != #", header:"test_cpp.hpp".}
proc `[]`*(this :var Vec3; index :cint) :cfloat {.importcpp:"#[#]", header:"test_cpp.hpp".}
proc `[]`*(this :Vec3; index :cint) :cfloat {.importcpp:"#[#]", header:"test_cpp.hpp".}
proc `+=`*(this :var Vec3; other :Vec3) :Vec3 {.importcpp:"# += #", discardable, header:"test_cpp.hpp".}
proc `-=`*(this :var Vec3; other :Vec3) :Vec3 {.importcpp:"# -= #", discardable, header:"test_cpp.hpp".}
proc `*=`*(this :var Vec3; scalar :cfloat) :Vec3 {.importcpp:"# *= #", discardable, header:"test_cpp.hpp".}
proc assign*(this :var Vec3; other :Vec3) :Vec3 {.importcpp:"# = #", discardable, header:"test_cpp.hpp".}
proc move*(this :var Vec3; other :Vec3) :Vec3 {.importcpp:"# = std::move(#)", discardable, header:"test_cpp.hpp".}
proc zero*() :Vec3 {.importcpp:"math::Vec3::zero(@)", header:"test_cpp.hpp".}
proc dot*(a :Vec3; b :Vec3) :cfloat {.importcpp:"math::dot(@)", header:"test_cpp.hpp".}
proc cross*(a :Vec3; b :Vec3) :Vec3 {.importcpp:"math::cross(@)", header:"test_cpp.hpp".}
proc clamp*[T](value :T; low :T; high :T) :T {.importcpp:"math::clamp<'*0>(@)", header:"test_cpp.hpp".}
type Shape* {.inheritable, importcpp:"math::nested::Shape", header:"test_cpp.hpp".} = object
proc destroy*(this :var Shape) {.importcpp:"#.~Shape()", header:"test_cpp.hpp".}
proc area*(this :Shape) :cfloat {.importcpp:"#.area(@)", header:"test_cpp.hpp".}
proc name*(this :Shape) :cstring {.importcpp:"#.name(@)", header:"test_cpp.hpp".}
type Circle* {.importcpp:"math::nested::Circle", header:"test_cpp.hpp".} = object of Shape
  radius* :cfloat
proc Circle_create*(radius :cfloat) :Circle {.importcpp:"math::nested::Circle(@)", constructor, header:"test_cpp.hpp".}
proc destroy*(this :var Circle) {.importcpp:"#.~Circle()", header:"test_cpp.hpp".}
proc area*(this :Circle) :cfloat {.importcpp:"#.area(@)", header:"test_cpp.hpp".}
proc name*(this :Circle) :cstring {.importcpp:"#.name(@)", header:"test_cpp.hpp".}
type Drawable* {.inheritable, importcpp:"math::nested::Drawable", header:"test_cpp.hpp".} = object
proc destroy*(this :var Drawable) {.importcpp:"#.~Drawable()", header:"test_cpp.hpp".}
proc draw*(this :Drawable) {.importcpp:"#.draw(@)", header:"test_cpp.hpp".}
type DrawableCircle* {.importcpp:"math::nested::DrawableCircle", header:"test_cpp.hpp".} = object of Circle
proc DrawableCircle_create*(radius :cfloat) :DrawableCircle {.importcpp:"math::nested::DrawableCircle(@)", constructor, header:"test_cpp.hpp".}
proc draw*(this :DrawableCircle) {.importcpp:"#.draw(@)", header:"test_cpp.hpp".}
