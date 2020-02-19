$(info "======= armv7_dispatcher.mk enter =========")

ARMV7_DISPATCHER_BIN := $(PRODUCT_OUT)/armv7_dispatcher.bin

$(ARMV7_DISPATCHER_BIN):
	$(hide) echo "=========== armv7_dispatcher Building !!! =========="
	$(MAKE) -C $(TARGET_ARM7_DISPACHER_SRC) clean;
	$(MAKE) -C $(TARGET_ARM7_DISPACHER_SRC);
	$(shell cp -af $(TARGET_ARM7_DISPACHER_SRC)/out/armv7_dispatcher.bin $(ARMV7_DISPATCHER_BIN));

.PHONY : $(ARMV7_DISPATCHER_BIN)

armv7_dispacher: $(ARMV7_DISPATCHER_BIN)

ALL_DEFAULT_INSTALLED_MODULES += $(ARMV7_DISPATCHER_BIN)


$(info "======= armv7_dispatcher.mk exit =========")
