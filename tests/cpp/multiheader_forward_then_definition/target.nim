import bindings

# Engine is forward-declared in a.hpp and fully defined in b.hpp; the binding
# must be a single, well-formed type usable from both entry points.
proc use(e: ptr Engine) =
  boot(e)
  discard e[].rpm()
