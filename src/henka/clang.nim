# Cable connector to the local libclang bindings/helpers
import ./clang/helpers ; export helpers
when defined(clang_selfhosted):
  import ./clang/api
else:
  import ./clang/minimal as api
export api
