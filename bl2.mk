$(info "======= bl2.mk enter =========")

BL2_BIN := $(PRODUCT_OUT)/pyrope-bl2.bin
LOADER_BIN := $(PRODUCT_OUT)/loader-emmc.img

$(BL2_BIN):
	$(hide) echo "=========== BL2 Building !!! =========="
	$(MAKE) -C $(TARGET_BL2_SRC) clean;
	$(MAKE) -C $(TARGET_BL2_SRC)  SUPPORT_OTA_AB_UPDATE=y;
	$(shell cp -af $(TARGET_BL2_SRC)/out/pyrope-bl2.bin $(BL2_BIN));
	$(SECURE_BINGEN) -c $(SOC_NAME) -t 3rdboot -i $(BL2_BIN) -o \
		$(LOADER_BIN) -l 0xb0fe0000 -e 0xb0fe0400 \
		-m 0x40200 -b 3 -p ${DEV_PORTNUM} \
		-m 0x1E0200 -b 3 -p ${DEV_PORTNUM} \
		-m 0x60200 -b 3 -p ${DEV_PORTNUM}

.PHONY : $(BL2_BIN)

bl2image: $(BL2_BIN)

ALL_DEFAULT_INSTALLED_MODULES += $(BL2_BIN)


$(info "======= bl2.mk exit =========")
