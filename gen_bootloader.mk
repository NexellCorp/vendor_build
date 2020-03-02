$(info "======= gen_bootloader.mk enter =========")

BOOT_LOADER_BIN := $(PRODUCT_OUT)/bootloader.img
COUNT_BY_512 := $(shell (echo $((${BOOTLOADER_PARTITION_SIZE}/512))) )

$(BOOT_LOADER_BIN): $(BL2_BIN) $(ARMV7_DISPATCHER_BIN) $(UBOOT_BIN) $(NONSECURE_BIN)
	$(hide) echo "=========== bootloader.img Building !!! =========="
	vendor/nexell/tools/make_bootloader.sh \
		$(BOOTLOADER_PARTITION_SIZE) \
		$(LOADER_BIN) \
		$(OFFSET_SECURE) \
		$(SECURE_BIN) \
		$(OFFSET_NONSECURE) \
		$(NONSECURE_BIN) \
		$(OFFSET_PARAM) \
		$(PARAM_BIN) 	\
		$(OFFSET_BOOTLOGO) 	\
		$(BOOT_LOGO) \
		$(BOOT_LOADER_BIN)

.PHONY : $(BOOT_LOADER_BIN)

bootloader: $(BOOT_LOADER_BIN)

ALL_DEFAULT_INSTALLED_MODULES += $(BOOT_LOADER_BIN)


$(info "======= gen_bootloader.mk exit =========")
