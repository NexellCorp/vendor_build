$(info "======= armv7_dispatcher.mk enter =========")

ARMV7_DISPATCHER_BIN := $(PRODUCT_OUT)/armv7_dispatcher.bin
SECURE_BIN :=  $(PRODUCT_OUT)/bl_mon.img

$(ARMV7_DISPATCHER_BIN):
	$(hide) echo "=========== armv7_dispatcher Building !!! =========="
	$(MAKE) -C $(TARGET_ARM7_DISPACHER_SRC) clean;
	$(MAKE) -C $(TARGET_ARM7_DISPACHER_SRC);
	$(shell cp -af $(TARGET_ARM7_DISPACHER_SRC)/out/armv7_dispatcher.bin $(ARMV7_DISPATCHER_BIN));
	$(SECURE_BINGEN) -c $(SOC_NAME) -t 3rdboot -i $(ARMV7_DISPATCHER_BIN) -o \
		$(SECURE_BIN) -l 0xffff0200 -e 0xffff0200 \
		-m 0x40200 -b 3 -p ${DEV_PORTNUM} \
		-m 0x1E0200 -b 3 -p ${DEV_PORTNUM} \
		-m 0x60200 -b 3 -p ${DEV_PORTNUM}

.PHONY : $(ARMV7_DISPATCHER_BIN)

armv7_dispacher: $(ARMV7_DISPATCHER_BIN)

ALL_DEFAULT_INSTALLED_MODULES += $(ARMV7_DISPATCHER_BIN)


$(info "======= armv7_dispatcher.mk exit =========")
