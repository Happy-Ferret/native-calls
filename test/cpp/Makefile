SOURCE_NAMES = testing tester_test transport_test jsonrpc_test rpc_type_test rpcruntime_test
LINKER_LIBS := NativeCalls

ifeq ($(FORCE),y)
$(info Forcing make)
forceall:
	$(MAKE) -B FORCE=n
endif



include $(NACL_SDK_ROOT)/tools/common.mk


TARGET = testing
LIBS = $(DEPS) $(LINKER_LIBS) ppapi_simple nacl_io ppapi_cpp ppapi gmock gtest pthread

CFLAGS = -I../../cpp -Wall -Wno-sign-compare
ifneq ($(TOOLCHAIN),pnacl)
CFLAGS += -Wno-unused-local-typedefs
endif


SOURCES = $(addsuffix .cpp,$(SOURCE_NAMES))


$(foreach src,$(SOURCES),$(eval $(call COMPILE_RULE,$(src),$(CFLAGS))))

ifeq ($(CONFIG),Release)
$(eval $(call LINK_RULE,$(TARGET)_unstripped,$(SOURCES),$(LIBS),$(DEPS)))
$(eval $(call STRIP_RULE,$(TARGET),$(TARGET)_unstripped))
else
$(eval $(call LINK_RULE,$(TARGET),$(SOURCES),$(LIBS),$(DEPS)))
endif

$(eval $(call NMF_RULE,$(TARGET),))
