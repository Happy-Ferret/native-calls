#include "gmock/gmock.h"
#include "ppapi/cpp/var.h"
#include "ppapi/cpp/var_array.h"
#include "RPCRuntime.h"

using namespace pprpc;
class MockRPCRuntime: public RPCRuntime{
public:
	MOCK_METHOD2(AddFunctor, bool(std::string name, RPCFunctor* functor));
	MOCK_METHOD1(GetFunctor, RPCFunctor*(std::string name));
	MOCK_METHOD2(CallFunctor, pp::Var(std::string name, const pp::VarArray* params));

	MOCK_METHOD1(HandleRequest, bool(const pp::Var& request));
	MOCK_METHOD1(HandleRequest, bool(const RPCRequest& request));
};
