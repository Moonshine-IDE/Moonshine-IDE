let mainApp;
const startSimulator = (app) => {
    mainApp = app;
    mainApp.timer = setInterval(() => {
        mainApp.on_sys_timer();
    }, sys.onsystimerperiod * 10);
    mainApp.on_sys_init();
};
const stopSimulator = (app) => {
    clearInterval(app.timer);
};
const bt = {};
const wln = {};
const tpram = {};
const fd = {
    files: {},
};
const ssi = {};
const kp = {};
const lcd = {};
const rtc = {};
const beep = {};
const io = {};
const pppoe = {};
const net = {};
const sys = {};
const stor = {};
const sock = {};
const ser = {};
const romfile = {
    files: {},
    currentFile: undefined,
    currentPointer: 0,
};
const ppp = {};
const pat = {};
const button = {};
const PL_BT_FC_ENABLED = 1;
const PL_BT_FC_DISABLED = 0;
const PL_BT_EVENT_DISABLED = 3;
const PL_BT_EVENT_ENABLED = 2;
const PL_BT_EVENT_DISCONNECTED = 1;
const PL_BT_EVENT_CONNECTED = 0;
const PL_WLN_BT_EMULATION_MODE_MICROCHIP = 2;
const PL_WLN_BT_EMULATION_MODE_NORDIC = 1;
const PL_WLN_BT_EMULATION_MODE_TI = 0;
const PL_WLN_MFGTX_RATE_72M = 13;
const PL_WLN_MFGTX_RATE_54M = 12;
const PL_WLN_MFGTX_RATE_48M = 11;
const PL_WLN_MFGTX_RATE_36M = 10;
const PL_WLN_MFGTX_RATE_24M = 9;
const PL_WLN_MFGTX_RATE_18M = 8;
const PL_WLN_MFGTX_RATE_12M = 7;
const PL_WLN_MFGTX_RATE_9M = 6;
const PL_WLN_MFGTX_RATE_6M = 5;
const PL_WLN_MFGTX_RATE_22M = 4;
const PL_WLN_MFGTX_RATE_11M = 3;
const PL_WLN_MFGTX_RATE_5_5M = 2;
const PL_WLN_MFGTX_RATE_2M = 1;
const PL_WLN_MFGTX_RATE_1M = 0;
const PL_WLN_MFGTX_MODE_DATATX = 2;
const PL_WLN_MFGTX_MODE_BURST = 1;
const PL_WLN_MFGTX_MODE_CONTINUOUS = 0;
const PL_WLN_WPA_CAST_MULTICAST = 1;
const PL_WLN_WPA_CAST_UNICAST = 0;
const PL_WLN_WPA_ALGORITHM_AES = 1;
const PL_WLN_WPA_ALGORITHM_TKIP = 0;
const PL_WLN_WPA_WPA2_PSK = 2;
const PL_WLN_WPA_WPA1_PSK = 1;
const PL_WLN_WPA_DISABLED = 0;
const PL_WLN_WEP_MODE_128 = 2;
const PL_WLN_WEP_MODE_64 = 1;
const PL_WLN_WEP_MODE_DISABLED = 0;
const PL_WLN_OWN_ADHOC = 2;
const PL_WLN_ASCAN_INFRASTRUCTURE = 1;
const PL_WLN_SCAN_ALL = 0;
const PL_WLN_TASK_SET_EAP_TTLS = 13;
const PL_WLN_TASK_SET_EAP_PEAP = 12;
const PL_WLN_TASK_SET_EAP_TLS = 11;
const PL_WLN_TASK_UPDATERSSI = 10;
const PL_WLN_TASK_ACTIVESCAN = 9;
const PL_WLN_TASK_SETWPA = 8;
const PL_WLN_TASK_NETWORK_STOP = 7;
const PL_WLN_TASK_NETWORK_START = 6;
const PL_WLN_TASK_DISASSOCIATE = 5;
const PL_WLN_TASK_SETWEP = 4;
const PL_WLN_TASK_SETTXPOWER = 3;
const PL_WLN_TASK_ASSOCIATE = 2;
const PL_WLN_TASK_SCAN = 1;
const PL_WLN_TASK_IDLE = 0;
const PL_WLN_EVENT_DISASSOCIATED = 1;
const PL_WLN_EVENT_DISABLED = 0;
const PL_WLN_UPGRADE_REGION_MONITOR = 1;
const PL_WLN_UPGRADE_REGION_MAIN = 0;
const PL_WLN_MODULE_TYPE_WA2000 = 1;
const PL_WLN_MODULE_TYPE_GA1000 = 0;
const PL_WLN_DOMAIN_JAPAN = 2;
const PL_WLN_DOMAIN_EU = 1;
const PL_WLN_DOMAIN_FCC = 0;
const WIFI_PHY_11N_5G = 11;
const WIFI_PHY_11AGN_MIXED = 10;
const WIFI_PHY_11BGN_MIXED = 9;
const WIFI_PHY_11AN_MIXED = 8;
const WIFI_PHY_11GN_MIXED = 7;
const WIFI_PHY_11N_2_4G = 6;
const WIFI_PHY_11ABGN_MIXED = 5;
const WIFI_PHY_11G = 4;
const WIFI_PHY_11ABG_MIXED = 3;
const WIFI_PHY_11A = 2;
const WIFI_PHY_11B = 1;
const WIFI_PHY_11BG_MIXED = 0;
const PL_WLN_OWN_NETWORK = 2;
const PL_WLN_ASSOCIATED = 1;
const PL_WLN_NOT_ASSOCIATED = 0;
const PL_WLN_BSS_MODE_ADHOC = 1;
const PL_WLN_BSS_MODE_INFRASTRUCTURE = 0;
const FD_ERROR_MOUNT_JOURNAL_COMMITTING_FAILED2 = 110;
const FD_ERROR_MOUNT_JOURNAL_COMMITTING_FAILED = 109;
const FD_ERROR_MOUNT_JOURNAL_DATA_INVALID = 108;
const FD_ERROR_FIND_GNSOFC_CHAIN_ERROR = 107;
const FD_ERROR_FIND_GNSOFC_CS_ERROR_1 = 106;
const FD_ERROR_FIND_GNSOFC_READ_ERROR_1 = 105;
const FD_ERROR_FIND_DATASECTOR_CS_ERROR_3 = 104;
const FD_ERROR_FIND_DATASECTOR_READ_ERROR_3 = 103;
const FD_ERROR_FIND_DATASECTOR_CS_ERROR_2 = 102;
const FD_ERROR_FIND_DATASECTOR_READ_ERROR_2 = 101;
const FD_ERROR_FIND_DATASECTOR_CS_ERROR_1 = 100;
const FD_ERROR_FIND_DATASECTOR_READ_ERROR_1 = 99;
const FD_ERROR_SAVE_FRT_SECTOR_WRITE_ERROR_2 = 98;
const FD_ERROR_SAVE_FRT_SECTOR_WRITE_ERROR_1 = 97;
const FD_ERROR_SAVE_FAT_SECTOR_WRITE_ERROR_2 = 96;
const FD_ERROR_SAVE_FAT_SECTOR_WRITE_ERROR_1 = 95;
const FD_ERROR_GNSOFC_WRITE_ERROR = 94;
const FD_ERROR_GNSOFC_CS_ERROR_4 = 93;
const FD_ERROR_GNSOFC_READ_ERROR_4 = 92;
const FD_ERROR_GNSOFC_CS_ERROR_3 = 91;
const FD_ERROR_GNSOFC_READ_ERROR_3 = 90;
const FD_ERROR_GNSOFC_CS_ERROR_2 = 89;
const FD_ERROR_GNSOFC_READ_ERROR_2 = 88;
const FD_ERROR_GNSOFC_CHAIN_ERROR_2 = 87;
const FD_ERROR_GNSOFC_CHAIN_ERROR_1 = 86;
const FD_ERROR_GNSOFC_CS_ERROR_1 = 85;
const FD_ERROR_GNSOFC_READ_ERROR_1 = 84;
const FD_ERROR_SETDATA_DATASECT_CS_ERROR_4 = 83;
const FD_ERROR_SETDATA_DATASECT_READ_ERROR_4 = 82;
const FD_ERROR_SETDATA_DATASECT_CS_ERROR_3 = 81;
const FD_ERROR_SETDATA_DATASECT_READ_ERROR_3 = 80;
const FD_ERROR_SETDATA_DATASECT_CS_ERROR_2 = 79;
const FD_ERROR_SETDATA_DATASECT_READ_ERROR_2 = 78;
const FD_ERROR_SETDATA_DATASECT_CS_ERROR_1 = 77;
const FD_ERROR_SETDATA_DATASECT_READ_ERROR_1 = 76;
const FD_ERROR_GETDATA_DATASECT_CS_ERROR_3 = 75;
const FD_ERROR_GETDATA_DATASECT_READ_ERROR_3 = 74;
const FD_ERROR_GETDATA_DATASECT_CS_ERROR_2 = 73;
const FD_ERROR_GETDATA_DATASECT_READ_ERROR_2 = 72;
const FD_ERROR_GETDATA_DATASECT_CS_ERROR_1 = 71;
const FD_ERROR_GETDATA_DATASECT_READ_ERROR_1 = 70;
const FD_ERROR_FINDFREESECTOR_FAT_CS_ERROR = 69;
const FD_ERROR_FINDFREESECTOR_FAT_READ_ERROR = 68;
const FD_ERROR_FINDFREESECTOR_FAT_INVALID_DATA = 67;
const FD_ERROR_FREESPACE_FAT_INVALID_DATA = 66;
const FD_ERROR_FREESPACE_FAT_CS_ERROR = 65;
const FD_ERROR_FREESPACE_FAT_READ_ERROR = 64;
const FD_ERROR_GETNEXTDIRMEMBER_FRT_CS_ERROR = 63;
const FD_ERROR_GETNEXTDIRMEMBER_FRT_READ_ERROR = 62;
const FD_ERROR_GETNUMFILES_FRT_CS_ERROR = 61;
const FD_ERROR_GETNUMFILES_FRT_READ_ERROR = 60;
const FD_ERROR_CREATE_FRT_WRITE_ERROR = 59;
const FD_ERROR_CREATE_FRT_CS_ERROR = 58;
const FD_ERROR_CREATE_FRT_READ_ERROR = 57;
const FD_ERROR_CREATE_DATASECTOR_WRITE_ERROR = 56;
const FD_ERROR_CREATE_FAT_WRITE_ERROR = 55;
const FD_ERROR_CREATE_FAT_CS_ERROR = 54;
const FD_ERROR_CREATE_FAT_READ_ERROR = 53;
const FD_ERROR_CREATE_COMMON_PORTION_ERROR = 52;
const FD_ERROR_DELETE_FAT_WRITE_ERROR_2 = 51;
const FD_ERROR_DELETE_INVALID_FAT_CHAIN_2 = 50;
const FD_ERROR_DELETE_INVALID_FAT_CHAIN_1 = 49;
const FD_ERROR_DELETE_FAT_CS_ERROR = 48;
const FD_ERROR_DELETE_FAT_READ_ERROR = 47;
const FD_ERROR_DELETE_FAT_WRITE_ERROR_1 = 46;
const FD_ERROR_DELETE_ENTRY_SECTOR_INVALID = 45;
const FD_ERROR_DELETE_FRT_WRITE_ERROR = 44;
const FD_ERROR_DELETE_FRT_CS_ERROR = 43;
const FD_ERROR_DELETE_FRT_READ_ERROR = 42;
const FD_ERROR_DELETE_COMMON_PORTION_ERROR = 41;
const FD_ERROR_SETATTRIBUTES_FRT_WRITE_ERROR = 40;
const FD_ERROR_SETATTRIBUTES_FRT_CS_ERROR = 39;
const FD_ERROR_SETATTRIBUTES_FRT_READ_ERROR = 38;
const FD_ERROR_SETATTRIBUTES_COMMON_PORTION_ERROR = 37;
const FD_ERROR_FLUSH_DATASECTOR_WRITE_ERROR = 36;
const FD_ERROR_OPEN_FRT_WRITE_ERROR = 35;
const FD_ERROR_OPEN_FRT_CS_ERROR = 34;
const FD_ERROR_OPEN_FRT_READ_ERROR = 33;
const FD_ERROR_OPEN_COMMON_PORTION_ERROR = 32;
const FD_ERROR_RENAME_FRT_WRITE_ERROR = 31;
const FD_ERROR_RENAME_FRT_CS_ERROR = 30;
const FD_ERROR_RENAME_FRT_READ_ERROR = 29;
const FD_ERROR_RENAME_COMMON_PORTION_ERROR = 28;
const FD_ERROR_FORMAT_FAT_WRITE_ERROR = 27;
const FD_ERROR_FORMAT_FRT_WRITE_ERROR = 26;
const FD_ERROR_FORMAT_ENDBOOT_WRITE_ERROR = 25;
const FD_ERROR_FORMAT_BOOT_WRITE_ERROR = 24;
const FD_ERROR_MOUNT_FAT_EMPTY_MAPPING_DETECTED = 23;
const FD_ERROR_MOUNT_FAT_INVALID_ACTIVE_SECTOR_COUNT = 22;
const FD_ERROR_MOUNT_FAT_WRITE_ERROR_2 = 21;
const FD_ERROR_MOUNT_FAT_WRITE_ERROR_1 = 20;
const FD_ERROR_FAT_LOGICAL_NUMBER_DUPLICATION = 19;
const FD_ERROR_MOUNT_FAT_LOGICAL_NUMBER_OOR = 18;
const FD_ERROR_MOUNT_FAT_CS_ERROR = 17;
const FD_ERROR_MOUNT_FAT_READ_ERROR = 16;
const FD_ERROR_MOUNT_FRT_EMPTY_MAPPING_DETECTED = 15;
const FD_ERROR_MOUNT_FRT_INVALID_ACTIVE_SECTOR_COUNT = 14;
const FD_ERROR_MOUNT_FRT_WRITE_ERROR_2 = 13;
const FD_ERROR_MOUNT_FRT_WRITE_ERROR_1 = 12;
const FD_ERROR_MOUNT_FRT_LOGICAL_NUMBER_DUPLICATION = 11;
const FD_ERROR_MOUNT_FRT_LOGICAL_NUMBER_OOR = 10;
const FD_ERROR_MOUNT_FRT_CS_ERROR = 9;
const FD_ERROR_MOUNT_FRT_READ_ERROR = 8;
const FD_ERROR_MOUNT_ENDBOOT_DATA_INVALID = 7;
const FD_ERROR_MOUNT_ENDBOOT_CS_ERROR = 6;
const FD_ERROR_MOUNT_ENDBOOT_READ_ERROR = 5;
const FD_ERROR_MOUNT_BOOT_DATA_INVALID = 4;
const FD_ERROR_MOUNT_BOOT_MARKER_INVALID = 3;
const FD_ERROR_MOUNT_BOOT_CS_ERROR = 2;
const FD_ERROR_MOUNT_BOOT_READ_ERROR = 1;
const FD_ERROR_NO_ADDITIONAL_ERROR_DATA = 0;
const PL_FD_FIND_LESSER_EQUAL = 5;
const PL_FD_FIND_LESSER = 4;
const PL_FD_FIND_GREATER_EQUAL = 3;
const PL_FD_FIND_GREATER = 2;
const PL_FD_FIND_NOT_EQUAL = 1;
const PL_FD_FIND_EQUAL = 0;
const PL_FD_CSUM_MODE_CALCULATE = 1;
const PL_FD_CSUM_MODE_VERIFY = 0;
const PL_FD_STATUS_FLASH_NOT_DETECTED = 16;
const PL_FD_STATUS_TRANSACTIONS_NOT_SUPPORTED = 15;
const PL_FD_STATUS_TRANSACTION_CAPACITY_EXCEEDED = 14;
const PL_FD_STATUS_TRANSACTION_NOT_YET_STARTED = 13;
const PL_FD_STATUS_TRANSACTION_ALREADY_STARTED = 12;
const PL_FD_STATUS_ALREADY_OPENED = 11;
const PL_FD_STATUS_NOT_OPENED = 10;
const PL_FD_STATUS_NOT_FOUND = 9;
const PL_FD_STATUS_NOT_READY = 8;
const PL_FD_STATUS_DATA_FULL = 7;
const PL_FD_STATUS_FILE_TABLE_FULL = 6;
const PL_FD_STATUS_DUPLICATE_NAME = 5;
const PL_FD_STATUS_INV_PARAM = 4;
const PL_FD_STATUS_FORMAT_ERR = 3;
const PL_FD_STATUS_CHECKSUM_ERR = 2;
const PL_FD_STATUS_FAIL = 1;
const PL_FD_STATUS_OK = 0;
const PL_SSI_ZMODE_ENABLED_ON_ZERO = 1;
const PL_SSI_ZMODE_ALWAYS_ENABLED = 0;
const PL_SSI_ACK_ALL_BUT_LAST = 3;
const PL_SSI_ACK_TX_ALL = 2;
const PL_SSI_ACK_RX = 1;
const PL_SSI_ACK_OFF = 0;
const PL_SSI_MODE_3 = 3;
const PL_SSI_MODE_2 = 2;
const PL_SSI_MODE_1 = 1;
const PL_SSI_MODE_0 = 0;
const PL_SSI_DIRECTION_LEFT = 1;
const PL_SSI_DIRECTION_RIGHT = 0;
const PL_KP_EVENT_LOCKEDUP = 5;
const PL_KP_EVENT_REPEATPRESSED = 4;
const PL_KP_EVENT_LONGPRESSED = 3;
const PL_KP_EVENT_PRESSED = 2;
const PL_KP_EVENT_RELEASED = 1;
const PL_KP_EVENT_LONGRELEASED = 0;
const PL_KP_MODE_BINARY = 1;
const PL_KP_MODE_MATRIX = 0;
const PL_LCD_TEXT_ORIENTATION_270 = 3;
const PL_LCD_TEXT_ORIENTATION_180 = 2;
const PL_LCD_TEXT_ORIENTATION_90 = 1;
const PL_LCD_TEXT_ORIENTATION_0 = 0;
const PL_LCD_TEXT_ALIGNMENT_BOTTOM_RIGHT = 8;
const PL_LCD_TEXT_ALIGNMENT_BOTTOM_CENTER = 7;
const PL_LCD_TEXT_ALIGNMENT_BOTTOM_LEFT = 6;
const PL_LCD_TEXT_ALIGNMENT_MIDDLE_RIGHT = 5;
const PL_LCD_TEXT_ALIGNMENT_MIDDLE_CENTER = 4;
const PL_LCD_TEXT_ALIGNMENT_MIDDLE_LEFT = 3;
const PL_LCD_TEXT_ALIGNMENT_TOP_RIGHT = 2;
const PL_LCD_TEXT_ALIGNMENT_TOP_CENTER = 1;
const PL_LCD_TEXT_ALIGNMENT_TOP_LEFT = 0;
const PL_LCD_PANELTYPE_COLOR = 1;
const PL_LCD_PANELTYPE_GRAYSCALE = 0;
const PL_BEEP_CANINT = 1;
const PL_BEEP_NOINT = 0;
const PL_NET_LINKSTAT_100BASET = 2;
const PL_NET_LINKSTAT_10BASET = 1;
const PL_NET_LINKSTAT_NOLINK = 0;
const PL_SYS_SPEED_FULL = 2;
const PL_SYS_SPEED_MEDIUM = 1;
const PL_SYS_SPEED_LOW = 0;
const PL_SYS_EXT_RESET_TYPE_RSTPIN = 4;
const PL_SYS_EXT_RESET_TYPE_BROWNOUT = 3;
const PL_SYS_EXT_RESET_TYPE_POWERUP = 2;
const PL_SYS_EXT_RESET_TYPE_WATCHDOG = 1;
const PL_SYS_EXT_RESET_TYPE_INTERNAL = 0;
const PL_SYS_RESET_TYPE_EXTERNAL = 1;
const PL_SYS_RESET_TYPE_INTERNAL = 0;
const PL_SYS_MODE_DEBUG = 1;
const PL_SYS_MODE_RELEASE = 0;
const PL_SOCK_HTTP_RQ_POST = 1;
const PL_SOCK_HTTP_RQ_GET = 0;
const PL_SOCK_PROTOCOL_RAW = 2;
const PL_SOCK_PROTOCOL_TCP = 1;
const PL_SOCK_PROTOCOL_UDP = 0;
const PL_SOCK_RECONMODE_3 = 3;
const PL_SOCK_RECONMODE_2 = 2;
const PL_SOCK_RECONMODE_1 = 1;
const PL_SOCK_RECONMODE_0 = 0;
const PL_SOCK_INCONMODE_ANY_IP_ANY_PORT = 3;
const PL_SOCK_INCONMODE_SPECIFIC_IP_ANY_PORT = 2;
const PL_SOCK_INCONMODE_SPECIFIC_IPPORT = 1;
const PL_SOCK_INCONMODE_NONE = 0;
const PL_SSTS_AC = 6;
const PL_SSTS_PC = 5;
const PL_SSTS_EST = 4;
const PL_SSTS_AO = 3;
const PL_SSTS_PO = 2;
const PL_SSTS_ARP = 1;
const PL_SSTS_CLOSED = 0;
const PL_SST_AC = NaN;
const PL_SST_PC = NaN;
const PL_SST_EST_AOPENED = NaN;
const PL_SST_EST_POPENED = NaN;
const PL_SST_EST = NaN;
const PL_SST_AO = NaN;
const PL_SST_PO = NaN;
const PL_SST_ARP = NaN;
const PL_SST_CL_DISCARDED_TOUT = 21;
const PL_SST_CL_DISCARDED_ARPFL = 20;
const PL_SST_CL_DISCARDED_AO_WCS = 19;
const PL_SST_CL_DISCARDED_PO_WCS = 18;
const PL_SST_CL_DISCARDED_CMD = 17;
const PL_SST_CL_ARESET_DERR = 16;
const PL_SST_CL_ARESET_TOUT = 15;
const PL_SST_CL_ARESET_RE_AC = 14;
const PL_SST_CL_ARESET_RE_PC = 13;
const PL_SST_CL_ARESET_RE_EST = 12;
const PL_SST_CL_ARESET_RE_AO = 11;
const PL_SST_CL_ARESET_RE_PO = 10;
const PL_SST_CL_ARESET_CMD = 9;
const PL_SST_CL_PRESET_STRANGE = 8;
const PL_SST_CL_PRESET_ACLOSING = 7;
const PL_SST_CL_PRESET_PCLOSING = 6;
const PL_SST_CL_PRESET_EST = 5;
const PL_SST_CL_PRESET_AOPENING = 4;
const PL_SST_CL_PRESET_POPENING = 3;
const PL_SST_CL_ACLOSED = 2;
const PL_SST_CL_PCLOSED = 1;
const PL_SST_CLOSED = 0;
const PL_SER_ET_TYPE2 = 2;
const PL_SER_ET_TYPE1 = 1;
const PL_SER_ET_DISABLED = 0;
const PL_SER_BB_8 = 1;
const PL_SER_BB_7 = 0;
const PL_SER_PR_SPACE = 4;
const PL_SER_PR_MARK = 3;
const PL_SER_PR_ODD = 2;
const PL_SER_PR_EVEN = 1;
const PL_SER_PR_NONE = 0;
const PL_SER_DCP_HIGHFORINPUT = 1;
const PL_SER_DCP_LOWFORINPUT = 0;
const PL_SER_FC_XONOFF = 2;
const PL_SER_FC_RTSCTS = 1;
const PL_SER_FC_DISABLED = 0;
const PL_SER_SI_HALFDUPLEX = 1;
const PL_SER_SI_FULLDUPLEX = 0;
const PL_SER_MODE_CLOCKDATA = 2;
const PL_SER_MODE_WIEGAND = 1;
const PL_SER_MODE_UART = 0;
const PL_PAT_CANINT = 1;
const PL_PAT_NOINT = 0;
const SHA1_FINISH = 1;
const SHA1_UPDATE = 0;
const MD5_FINISH = 1;
const MD5_UPDATE = 0;
const FTOSTR_MODE_PLAIN = 2;
const FTOSTR_MODE_ME = 1;
const FTOSTR_MODE_AUTO = 0;
const PL_MONTH_DECEMBER = 12;
const PL_MONTH_NOVEMBER = 11;
const PL_MONTH_OCTOBER = 10;
const PL_MONTH_SEPTEMBER = 9;
const PL_MONTH_AUGUST = 8;
const PL_MONTH_JULY = 7;
const PL_MONTH_JUNE = 6;
const PL_MONTH_MAY = 5;
const PL_MONTH_APRIL = 4;
const PL_MONTH_MARCH = 3;
const PL_MONTH_FEBRUARY = 2;
const PL_MONTH_JANUARY = 1;
const PL_DOW_SUNDAY = 7;
const PL_DOW_SATURDAY = 6;
const PL_DOW_FRIDAY = 5;
const PL_DOW_THURSDAY = 4;
const PL_DOW_WEDNESDAY = 3;
const PL_DOW_TUESDAY = 2;
const PL_DOW_MONDAY = 1;
const PL_REDIR_SOCK15 = 21;
const PL_REDIR_SOCK14 = 20;
const PL_REDIR_SOCK13 = 19;
const PL_REDIR_SOCK12 = 18;
const PL_REDIR_SOCK11 = 17;
const PL_REDIR_SOCK10 = 16;
const PL_REDIR_SOCK9 = 15;
const PL_REDIR_SOCK8 = 14;
const PL_REDIR_SOCK7 = 13;
const PL_REDIR_SOCK6 = 12;
const PL_REDIR_SOCK5 = 11;
const PL_REDIR_SOCK4 = 10;
const PL_REDIR_SOCK3 = 9;
const PL_REDIR_SOCK2 = 8;
const PL_REDIR_SOCK1 = 7;
const PL_REDIR_SOCK0 = 6;
const PL_REDIR_SER3 = 4;
const PL_REDIR_SER2 = 3;
const PL_REDIR_SER1 = 2;
const PL_REDIR_SER0 = 1;
const PL_REDIR_SER = 1;
const PL_REDIR_NONE = 0;
const FALLING = 1;
const RISING = 0;
const PL_HORIZONTAL = 1;
const PL_VERTICAL = 0;
const BACK = 1;
const FORWARD = 0;
const REJECTED = 1;
const ACCEPTED = 0;
const INVALID = 1;
const VALID = 0;
const WLN_REJ = 2;
const WLN_NG = 1;
const WLN_OK = 0;
const NG = 1;
const OK = 0;
const HIGH = 1;
const LOW = 0;
const ENABLED = 1;
const DISABLED = 0;
const YES = 1;
const yes = 1;
const NO = 0;
const no = 0;
const PL_ON = 1;
const PL_OFF = 0;
const PL_INT_NULL = 8;
const PL_INT_NUM_7 = 7;
const PL_INT_NUM_6 = 6;
const PL_INT_NUM_5 = 5;
const PL_INT_NUM_4 = 4;
const PL_INT_NUM_3 = 3;
const PL_INT_NUM_2 = 2;
const PL_INT_NUM_1 = 1;
const PL_INT_NUM_0 = 0;
const PL_IO_PORT_NUM_0 = 0;
const PL_IO_NULL = 56;
const PL_IO_NUM_55 = 55;
const PL_IO_NUM_54 = 54;
const PL_IO_NUM_53 = 53;
const PL_IO_NUM_52 = 52;
const PL_IO_NUM_51 = 51;
const PL_IO_NUM_50 = 50;
const PL_IO_NUM_49 = 49;
const PL_IO_NUM_48 = 48;
const PL_IO_NUM_47 = 47;
const PL_IO_NUM_46 = 46;
const PL_IO_NUM_45_CO = 45;
const PL_IO_NUM_44 = 44;
const PL_IO_NUM_43 = 43;
const PL_IO_NUM_42 = 42;
const PL_IO_NUM_41 = 41;
const PL_IO_NUM_40 = 40;
const PL_IO_NUM_39 = 39;
const PL_IO_NUM_38 = 38;
const PL_IO_NUM_37 = 37;
const PL_IO_NUM_36 = 36;
const PL_IO_NUM_35 = 35;
const PL_IO_NUM_34 = 34;
const PL_IO_NUM_33 = 33;
const PL_IO_NUM_32 = 32;
const PL_IO_NUM_31 = 31;
const PL_IO_NUM_30 = 30;
const PL_IO_NUM_29 = 29;
const PL_IO_NUM_28 = 28;
const PL_IO_NUM_27 = 27;
const PL_IO_NUM_26 = 26;
const PL_IO_NUM_25 = 25;
const PL_IO_NUM_24 = 24;
const PL_IO_NUM_23_INT7 = 23;
const PL_IO_NUM_22_INT6 = 22;
const PL_IO_NUM_21_INT5 = 21;
const PL_IO_NUM_20_INT4 = 20;
const PL_IO_NUM_19_INT3 = 19;
const PL_IO_NUM_18_INT2 = 18;
const PL_IO_NUM_17_INT1 = 17;
const PL_IO_NUM_16_INT0 = 16;
const PL_IO_NUM_15_TX3 = 15;
const PL_IO_NUM_14_RX3 = 14;
const PL_IO_NUM_13_TX2 = 13;
const PL_IO_NUM_12_RX2 = 12;
const PL_IO_NUM_11_TX1 = 11;
const PL_IO_NUM_10_RX1 = 10;
const PL_IO_NUM_9_TX0 = 9;
const PL_IO_NUM_8_RX0 = 8;
const PL_IO_NUM_7 = 7;
const PL_IO_NUM_6 = 6;
const PL_IO_NUM_5 = 5;
const PL_IO_NUM_4 = 4;
const PL_IO_NUM_3 = 3;
const PL_IO_NUM_2 = 2;
const PL_IO_NUM_1 = 1;
const PL_IO_NUM_0 = 0;
const PL_SOCK_INTERFACE_PPPOE = 4;
const PL_SOCK_INTERFACE_PPP = 3;
const PL_SOCK_INTERFACE_WLN = 2;
const PL_SOCK_INTERFACE_NET = 1;
const PL_SOCK_INTERFACE_NULL = 0;
function val(sourcestr) {
    return parseInt(sourcestr);
}
function lval(sourcestr) {
    return parseInt(sourcestr);
}
function str(num) {
    return num.toString();
}
function lstr(num) {
    return num.toString();
}
function stri(num) { }
function lstri(num) { }
function hex(num) { }
function lhex(num) { }
function bin(num) { }
function lbin(num) { }
function left(sourcestr, len) {
    return sourcestr.substr(0, len);
}
function right(sourcestr, len) {
    return sourcestr.substr(sourcestr.length - len);
}
function mid(sourcestr, frompos, len) {
    return sourcestr.substr(frompos, len);
}
function len(sourcestr) {
    return sourcestr.length;
}
function instr(frompos, sourcestr, substr, num) {
    let pos = sourcestr.indexOf(substr, frompos);
    if (pos == -1) {
        pos = 255;
    }
    return pos;
}
function asc(sourcestr) { }
function chr(asciicode) {
    return String.fromCharCode(asciicode);
}
function ddstr(str) { }
function ddval(str) { }
function strgen(len, substr) { }
function strsum(sourcestr) { }
function weekday(daycount) { }
function year(daycount) { }
function month(daycount) { }
function date(daycount) { }
function daycount(year, month, date) { }
function hours(mincount) { }
function minutes(mincount) { }
function mincount(hours, minutes) { }
//<b>PLATFORM SYSCALL. </b><br><br>
//Returns the minutes number for a given hours and minutes. Minutes are counted from midnight (00:00 is minute #0).<br><br>
//If any input parameter is illegal (hours exceeds 23, minutes exceeds 59, etc.) this syscall will return 65535.
//This error value cannot be confused with an actual valid minute number since the maximum minute number cannot exceed 1439.<br><br>
//See also <font color="teal"><b>weekday</b></font>, <font color="teal"><b>year</b></font>, 
//<font color="teal"><b>month</b></font>, <font color="teal"><b>date</b></font>, 
//<font color="teal"><b>hours</b></font>, <font color="teal"><b>minutes</b></font>, and 
//<font color="teal"><b>daycount </b></font>syscalls.
//--------------------------------------------------------------------
function cfloat(num) { }
//<b>PLATFORM SYSCALL. </b><br><br>
//Floating-point calculations can lead to invalid result (#INF, -#INF errors, as per IEEE specification).<br><br>
//When your application is in the debug mode you will get a FPERR exception if such an error is encountered. <br><br>
//In the release mode the Virtual Machine won't generate an exception, yet your application may need to know if a certain floating-point 
//variable contains correct value. This is where cfloat() function comes handy. <br><br>
//The <font color="teal"><b>cfloat() </b></font>returns <font color="olive"><b>0- VALID </b></font>if the floating-point
//variable num contains a valid value, and <font color="olive"><b>1- INVALID </b></font>if the num contains invalid value.
//--------------------------------------------------------------------
//<b>INTRINSIC PLATFORM SYSCALL. </b><br><br>
//--------------------------------------------------------------------
//Choose between plain and mantissa/exponent format automatically. Format that results in the
//shortest string will be selected.
//Use mantissa/exponent format.
//Use regular plain format, not mantissa/exponent representation. 
function ftostr(num, mode, rnd) { }
//<b>PLATFORM SYSCALL. </b><br><br>
//Converts real value into its string representation. <font color="teal"><b>Ftostr() </b></font>function offers two formatting 
//options: mode argument selects mantissa/exponent, plain, or "whichever is more compact" format for the output string.<br><br>
//Rnd argument defines how many digits (both in the integer and fractional part) the number should be rounded to.
//--------------------------------------------------------------------
function strtof(str) { }
//<b>PLATFORM SYSCALL. </b><br><br>
//Converts string representation of a real value into a real value. You must keep in mind that floating-point calculations
//are inherently imprecise. Not every value can be converted into its exact floating-point representation.<br><br>
//Also, <font color="teal"><b>strtof() </b></font>can be invoked implicitly (real_var=string_var).
//--------------------------------------------------------------------
//<b>INTRINSIC PLATFORM SYSCALL. </b><br><br>
//--------------------------------------------------------------------
//<b>INTRINSIC PLATFORM SYSCALL. </b><br><br>
//--------------------------------------------------------------------
//<b>INTRINSIC PLATFORM SYSCALL. </b><br><br>
//--------------------------------------------------------------------
//<b>INTRINSIC PLATFORM SYSCALL. </b><br><br>
//--------------------------------------------------------------------
//<b>INTRINSIC PLATFORM SYSCALL. </b><br><br>
//--------------------------------------------------------------------
//<b>INTRINSIC PLATFORM SYSCALL. </b><br><br>
//--------------------------------------------------------------------
//<b>INTRINSIC PLATFORM SYSCALL. </b><br><br>
//--------------------------------------------------------------------
//<b>INTRINSIC PLATFORM SYSCALL. </b><br><br>
//--------------------------------------------------------------------
//<b>INTRINSIC PLATFORM SYSCALL. </b><br><br>
//--------------------------------------------------------------------
//<b>INTRINSIC PLATFORM SYSCALL. </b><br><br>
//--------------------------------------------------------------------
//<b>INTRINSIC PLATFORM SYSCALL. </b><br><br>
//--------------------------------------------------------------------
//<b>INTRINSIC PLATFORM SYSCALL. </b><br><br>
//--------------------------------------------------------------------
//<b>INTRINSIC PLATFORM SYSCALL. </b><br><br>
//--------------------------------------------------------------------
//<b>INTRINSIC PLATFORM SYSCALL. </b><br><br>
//--------------------------------------------------------------------
//<b>INTRINSIC PLATFORM SYSCALL. </b><br><br>
//--------------------------------------------------------------------
//<b>INTRINSIC PLATFORM SYSCALL. </b><br><br>
//--------------------------------------------------------------------
//<b>INTRINSIC PLATFORM SYSCALL. </b><br><br>
//--------------------------------------------------------------------
//<b>INTRINSIC PLATFORM SYSCALL. </b><br><br>
//--------------------------------------------------------------------
//<b>INTRINSIC PLATFORM SYSCALL. </b><br><br>
//--------------------------------------------------------------------
//<b>INTRINSIC PLATFORM SYSCALL. </b><br><br>
//--------------------------------------------------------------------
//<b>INTRINSIC PLATFORM SYSCALL. </b><br><br>
//--------------------------------------------------------------------
//<b>INTRINSIC PLATFORM SYSCALL. </b><br><br>
//--------------------------------------------------------------------
//<b>INTRINSIC PLATFORM SYSCALL. </b><br><br>
//--------------------------------------------------------------------
//<b>INTRINSIC PLATFORM SYSCALL. </b><br><br>
//--------------------------------------------------------------------
//<b>INTRINSIC PLATFORM SYSCALL. </b><br><br>
//--------------------------------------------------------------------
//<b>INTRINSIC PLATFORM SYSCALL. </b><br><br>
//--------------------------------------------------------------------
//<b>INTRINSIC PLATFORM SYSCALL. </b><br><br>
//--------------------------------------------------------------------
//<b>INTRINSIC PLATFORM SYSCALL. </b><br><br>
//--------------------------------------------------------------------
//<b>INTRINSIC PLATFORM SYSCALL. </b><br><br>
//--------------------------------------------------------------------
//<b>INTRINSIC PLATFORM SYSCALL. </b><br><br>
//--------------------------------------------------------------------
//<b>INTRINSIC PLATFORM SYSCALL. </b><br><br>
//--------------------------------------------------------------------
//<b>INTRINSIC PLATFORM SYSCALL. </b><br><br>
//--------------------------------------------------------------------
//<b>INTRINSIC PLATFORM SYSCALL. </b><br><br>
//--------------------------------------------------------------------
//<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<<
//<b>INTRINSIC PLATFORM SYSCALL. </b><br><br>
//--------------------------------------------------------------------
//<b>INTRINSIC PLATFORM SYSCALL. </b><br><br>
//--------------------------------------------------------------------
//Set this mode for all data portions except the last one.
//Set this mode for the last data portion; also use this selection if you only have a single data portion.
function md5(str, input_hash, md5_mode, total_len) { }
//<b>PLATFORM SYSCALL. </b><br><br>
//Generates MD5 hash on the <b>str </b>string. Returns 16-character hash string; an empty string when invalid str or input_hash argument was detected.
//<br><br>
//<b>str</b> -- String containing (the next portion of) the input data to generate MD5 hash on. When md5_mode= <font color="olive"><b>0- MD5_UPDATE</b></font>, 
//this string must be 64, 128, or 192 characters in length.  Any other length will result in error and the function will return an empty string. 
//When md5_mode= <font color="olive"><b>1- md5_FINISH</b></font>, this string can have any length (up to 255 bytes).
//<br>
//<b>input_hash</b> -- Hash obtained as a result of MD5 calculation on the previous data portion. Leave it empty for the first portion of data.
//Use the result of MD5 calculation on the previous data portion for the second and all subsequent portions of data.
//The result of MD5 is always 16 characters long, so passing the string of any other length (except 0 -- see above) will result in error and this function will return an empty string.
//<br>
//<b>md5_mode</b> -- <font color="olive"><b>0- MD5_UPDATE </b></font> (set this mode for all data portions except the last one), or <font color="olive"><b>1- md5_FINISH </b></font>
//(set this mode for the last data portion; also use this selection if you only have a single data portion).
//<br>
//<b>total_len</b> -- Total length of processed data (in all data portions combined). Only relevant when md5_mode= <font color="olive"><b>1- md5_FINISH</b></font>. 
//That is, only relevant for the last or a single data portion.
//<br><br>
//MD5 is a standard method of calculating hash codes on data of any size. The amount of input data can often exceed maximum capacity of string variables (255 characters).
//The md5 method can be invoked repeatedly in order to process the data of any size.
//<br><br>
//See also:
//<font color="teal"><b>sha1</b</font>.
//--------------------------------------------------------------------
//Set this mode for all data portions except the last one.
//Set this mode for the last data portion; also use this selection if you only have a single data portion.
function sha1(str, input_hash, sha1_mode, totallen) { }
//<b>PLATFORM SYSCALL. </b><br><br>
//Generates SHA1 hash on the <b>str </b>string. Returns 20-character hash string; an empty string when invalid str or input_hash argument was detected.
//<br><br>
//<b>str</b> -- String containing (the next portion of) the input data to generate SHA1 hash on. When sha1_mode= <font color="olive"><b>0- SHA1_UPDATE</b></font>, 
//this string must be 64, 128, or 192 characters in length. Any other length will result in error and the function will return an empty string. 
//When sha1_mode= <font color="olive"><b>1- SHA1_FINISH</b></font>, this string can have any length (up to 255 bytes).
//<br>
//<b>input_hash</b> -- Hash obtained as a result of SHA1 calculation on the previous data portion. Leave it empty for the first portion of data.
//Use the result of SHA1 calculation on the previous data portion for the second and all subsequent portions of data.
//The result of SHA1 is always 20 characters long, so passing the string of any other length (except 0 -- see above) will result in error and this function will return an empty string.
//<br>
//<b>md5_mode</b> -- <font color="olive"><b>0- SHA1_UPDATE</b></font>(set this mode for all data portions except the last one), or <font color="olive"><b>1- SHA1_FINISH </b></font>
//(set this mode for the last data portion; also use this selection if you only have a single data portion).
//<br>
//<b>total_len</b> -- Total length of processed data (in all data portions combined). Only relevant when sha1_mode= <font color="olive"><b>1- SHA1_FINISH</b></font>. 
//That is, only relevant for the last or a single data portion.
//<br><br>
//SHA1 is a standard method of calculating hash codes on data of any size. The amount of input data can often exceed maximum capacity of string variables (255 characters).
//The sha1 method can be invoked repeatedly in order to process the data of any size.
//<br><br>
//See also:
//<font color="teal"><b>md5</b</font>.
//--------------------------------------------------------------------
function random(len) { }
//<b>PLATFORM SYSCALL. </b><br><br>
//Generates a string consisting of <b>len </b>random characters.
//--------------------------------------------------------------------
//<b>INTRINSIC PLATFORM SYSCALL. </b><br><br>
//--------------------------------------------------------------------
//<b>INTRINSIC PLATFORM SYSCALL. </b><br><br>
//--------------------------------------------------------------------
function insert(dest_str, pos, insert_str) { }
//<b>PLATFORM SYSCALL. </b><br><br>
//Inserts insert_str string into the dest_str string at the insert position pos. Returns the new length of dest_str.
//<br><br>
//This is an insert with overwrite, meaning that the insert_str will overwrite a portion of the dest_str.
//<br><br>
//Dest_str length can increase as a result of this operation (but not beyond declared string capacity). This will happen if the insertion position does
//not allow the source_str to fit within the current length of the dest_string.
//--------------------------------------------------------------------
function aes128enc(key, plain) { }
//<b>PLATFORM SYSCALL. </b><br><br>
//Encrypts data in 16-byte blocks according to the AES128 algorithm. Returns encrypted data (which will consist of complete 16-character blocks).
//<br><br>
//<b>Key </b>-- Encryption key. Must be 16 characters long, or NULL string will be returned.
//<br><br>
//<b>Plain </b>-- Plain (unencrypted) data. Will be processed in 16-byte blocks. Last incomplete block will be padded with zeroes. 
//<br><br>
//Not supported on the EM500W platform.
//<b>See also: </b>aes128dec, rc4.
//--------------------------------------------------------------------
function aes128dec(key, cypher) { }
//<b>PLATFORM SYSCALL. </b><br><br>
//Decrypts data in 16-byte blocks according to the AES128 algorithm. Returns decrypted data (which will consist of complete 16-character blocks).
//<br><br>
//<b>Key </b>-- Encryption key. Must be 16 characters long, or NULL string will be returned.
//<br><br>
//<b>Cypher </b>-- Encrypted data, must consist of one or more complete 16-character blocks, or NULL string will be returned. 
//<br><br>
//Not supported on the EM500W platform.
//<br><br>
//<b>See also: </b>aes128dec, rc4.
//--------------------------------------------------------------------
function rc4(key, skip, data) { }
//<b>PLATFORM SYSCALL. </b><br><br>
//Encrypts/decrypts the data stream according to the RC4 algorithm. Returns processed data.
//<br><br>
//<b>Key </b>-- Encryption key, can have any length.
//<br><br>
//<b>Skip </b>-- The number of "skip" iterations. These are additional iterations added past the standard "key scheduling algorithm". Set this argument to 0 to obtain
//standard encryption results compatible with other systems.
//<br><br>
//<b>Key </b>-- Data to encrypt/decrypt.
//<br><br>
//With RC4 algorithm, the same function is used both for encrypting and decrypting the data.
//<br><br>
//<b>See also: </b>aes128enc, aes128dec.
//--------------------------------------------------------------------
function strand(str1, str2) { }
//<b>PLATFORM SYSCALL. </b><br><br>
//Returns a string containing the result of logical AND operation on data in str1 and str2 arguments.
//<br><br>
//This function treats data in str1 and str2 as two byte arrays. Logical AND operation is performed on corresponding byte pairs (first byte of str1 AND first byte of str2, etc.).
//<br><br>
//If one of the arguments contains less bytes, then this argument is padded with zeroes prior to performing logical AND operation.
//<br><br>
//<b>See also: </b>stror, strxor.
//--------------------------------------------------------------------
function stror(str1, str2) { }
//<b>PLATFORM SYSCALL. </b><br><br>
//Returns a string containing the result of logical OR operation on data in str1 and str2 arguments.
//<br><br>
//This function treats data in str1 and str2 as two byte arrays. Logical OR operation is performed on corresponding byte pairs (first byte of str1 OR first byte of str2, etc.).
//<br><br>
//If one of the arguments contains less bytes, then this argument is padded with zeroes prior to performing logical OR operation.
//<br><br>
//<b>See also: </b>strand, strxor.
//--------------------------------------------------------------------
function strxor(str1, str2) { }
//<b>PLATFORM SYSCALL. </b><br><br>
//Returns a string containing the result of logical exclusive OR (XOR) operation on data in str1 and str2 arguments.
//<br><br>
//This function treats data in str1 and str2 as two byte arrays. Logical XOR operation is performed on corresponding byte pairs (first byte of str1 XOR first byte of str2, etc.).
//<br><br>
//If one of the arguments contains less bytes, then this argument is padded with zeroes prior to performing logical XOR operation.
//<br><br>
//<b>See also: </b>strand, stror.
//--------------------------------------------------------------------
//<b>INTRINSIC PLATFORM SYSCALL. </b><br><br>
//--------------------------------------------------------------------
//<b>INTRINSIC PLATFORM SYSCALL. </b><br><br>
//--------------------------------------------------------------------
//<b>INTRINSIC PLATFORM SYSCALL. </b><br><br>
//--------------------------------------------------------------------
//--------------------------------------------------------------------
//--------------------------------------------------------------------
//<b>METHOD.</b>
//--------------------------------------------------------------------
//<b>METHOD.</b>//**************************************************************************************************
//       BUTTON object
//**************************************************************************************************
//All programmable boards, programmable serial controllers, and Tibbo Project System (TPS) devices offered by Tibbo feature a button referred to as the "setup" or "MD" button ("MD" stands for "mode").
//<br><br>
//All programmable Tibbo modules have a line for connecting this button externally.
//<br><br>
//When a programmable Tibbo device is executing a Tibbo BASIC/C application, the MD button can be used as a general-purpose input button.
//--------------------------------------------------------------------
Object.defineProperty(button, 'pressed', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (BYTE).</b><br><br>
//Returns the current button state.
//<br><br>
//This property reflects the immediate state of the hardware at the very moment the property is read -- no "debouncing" performed.
//--------------------------------------------------------------------
Object.defineProperty(button, 'time', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (BYTE).</b><br><br>
//Returns the time (in 0.5 second intervals) elapsed since the button was last pressed or released (whichever happened more recently).
//<br><br>
//This property will only show a meaningful value when read inside the on_button_pressed or on_button_released event handler.
//<br><br>
//The value of this property maxes out at 255 (127.5 seconds).
//<br><br>
//The elapsed time is not counted while the execution of your application is paused (during debugging).
//--------------------------------------------------------------------
//<b>EVENT of the button object. </b><br><br> 
//Generated when the MD button on your device is pressed (MD line goes LOW).
//<br><br>
//Multiple on_button_pressed events may be waiting in the event queue.
//<br><br>
//You can check the time elapsed since the preceding on_button_released event (or execution start) by reading the value of the button.time read-only property.
//--------------------------------------------------------------------
//<b>EVENT of the button object. </b><br><br> 
//Generated when the MD button on your device is released (MD line goes HIGH).
//<br><br>
//Multiple on_button_released events may be waiting in the event queue.
//<br><br>
//You can check the time elapsed since the preceding on_button_pressed event by reading the value of the button.time read-only property.//**************************************************************************************************
//       PAT (LED pattern) object
//**************************************************************************************************
//The pat. object allows you to "play" blink patters on up to five LED pairs or channels, each pair typically consisting of red and green LEDs.
//<br><br>
//Patterns only play when your application is executing and pause when you application is not running.
//<br><br>
//Channel 0 is the primary channel of your system. It utilizes green and red status LEDs (or LED lines) that are present on all programmable Tibbo devices.
//Channel 0 requires no configuration -- your code can proceed straight to playing patterns.
//<br><br>
//The remaining four channels (1-4) use regular I/O lines of Tibbo devices.
//Mapping properties allow you to select control I/O lines for LEDs of channels 1-4.
//<br><br>
//<b>On this platform you need to configure LED control lines of channels 1-4 as outputs. This is done through the io.enabled property.</b>
//--------------------------------------------------------------------
//<b>PLATFORM CONSTANT. </b><br><br> Tells the pat.play method that the new pattern can only be loaded if no pattern is playing at the moment.
//<b>PLATFORM CONSTANT. </b><br><br> Tells the pat.play method that the new pattern can be loaded even if another pattern is currently playing.
pat.play = function (pattern, patint) { };
//<b>METHOD. </b><br><br> 
//For the currently selected pattern channel (selection is made through the pat.channel property), loads a new LED pattern to play.
//<br><br>
//The pattern string defines the pattern, for example: "R-G-B~*".
//<br><br>
//The meaning of characters:
//<br><br>
//'-': Both LEDs are off.
//<br><br>
//'R' or 'r': Red LED on (green LED off).
//<br><br>
//'G' or 'g': Green LED on (red LED off).
//<br><br>
//'B' or 'b': Both LEDs on.
//<br><br>
//'~': Looped pattern. This character can be inserted anywhere in the pattern string. 
//<br><br>
//'*': Double the speed of playing this pattern. Can be inserted anywhere in the pattern string. Applies to the entire string. You can use up to two * characters, meaning that you can quadruple the normal speed of the output. 
//<br><br>
//The patint argument determines if this method's invocation is allowed to interrupt another pattern that is already playing. 
//--------------------------------------------------------------------
Object.defineProperty(pat, 'channel', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (BYTE), DEFAULT VALUE= 0 (channel 0). </b><br><br>
//Selects/returns the pattern channel to work with. This selection is related to the pat.play method, as well as io.redmap and io.greenmap properties.
//<br><br>
//Note that this property's value will be set automatically when the event handler for the on_pat event is entered.
//--------------------------------------------------------------------
Object.defineProperty(pat, 'greenmap', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE: channel 0: (-1), R/0; channels 1-4: PL_IO_NULL.</b><br><br>
//For the currently selected pattern channel (selection is made through the pat.channel property), sets/returns the number of the I/O line that will act as the control line for this channel's green LED.
//<br><br>
//Channel 0 does not require configuration. Writing to this property will only work on channels 1-4.
//<br><br>
//<b>On this platform you must also configure I/O lines of channels 1-4 as outputs. This is done through the io.enabled property of the io. object.</b>
//--------------------------------------------------------------------
Object.defineProperty(pat, 'redmap', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE: channel 0: (-1), R/0; channels 1-4: PL_IO_NULL.</b><br><br>
//For the currently selected pattern channel (selection is made through the pat.channel property), sets/returns the number of the I/O line that will act as the control line for this channel's red LED.
//<br><br>
//Channel 0 does not require configuration. Writing to this property will only work on channels 1-4.
//<br><br>
//<b>On this platform you must also configure I/O lines of channels 1-4 as outputs. This is done through the io.enabled property of the io. object.</b>
//--------------------------------------------------------------------
//<b>EVENT of the pat object. </b><br><br>
//Generated when an LED pattern finishes "playing". This can only happened for "non-looped" patterns.
//<br><br>
//Multiple on_pat events may be waiting in the event queue (but not exceeding one per channel).
//<br><br>
//On entering the event handler, pat.channel will be set to the channel number for which this event was generated. 
//<br><br>
//The event won't be generated if the current pattern is superseded (overwritten) by a new call to pat.play.//**************************************************************************************************
//       PPP object
//**************************************************************************************************
//The ppp object represents a ppp interface of your device (i.e. for accessing TCP/IP networks thru landline or GPRS modems).
//This object only specifies various parameters related to the ppp interface (such as the IP address) and is not responsible for
//sending/transmitting network data. The latter is the job of the sock object.
//--------------------------------------------------------------------
Object.defineProperty(ppp, 'enabled', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0- NO (not enabled). </b><br><br>
//Enables/disables PPP interface on the serial port specified by the ppp.portnum property. 
//<br><br>
//Once this property is set to 1- YES, the selected serial port seizes to be under the control of your application and works exclusively for the ppp. object.
//PPP channel setup (ppp.buffrq, ppp.ip, ppp.portnum) can only be altered when the ppp. object is disabled.
//--------------------------------------------------------------------
Object.defineProperty(ppp, 'portnum', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (BYTE), DEFAULT VALUE= 0 (serial port #0 selected). </b><br><br>
//Sets/returns the number of the serial port that will be used by the ppp. object.
//<br><br>
//Once the PPP interface is enabled (ppp.enabled= 1- YES), the selected serial port seizes to be under the control of your application and works exclusively for the ppp. object.
//The value of this property won't exceed ser.numofports-1 (even if you attempt to set a higher value).
//You can only change this property when the PPP channel is disabled (ppp.enabled= 0- NO).
//--------------------------------------------------------------------
ppp.buffrq = function (numpages) { };
//<b>METHOD.</b>
//<br><br>
//Pre-requests "numpages" number of buffer pages (1 page= 256 bytes) for the buffer of the ppp object.
//<br><br>
//This method returns the actual number of pages that can be allocated.
//Actual allocation happens when the sys.buffalloc method is used.
//<br><br>
//The PPP object will be unable to operate properly if its buffer has inadequate capacity. Recommented buffer size is 5 pages.
//<br><br>
//The buffer can only be allocated when the PPP channel is not enabled (ppp.enabled= 0- NO).
//Executing sys.buffalloc while ppp.enabled= 1- YES will leave the buffer size unchanged.
//<br><br>
//The actual current buffer size can be verified through the ppp.buffsize read-only property.
//--------------------------------------------------------------------
Object.defineProperty(ppp, 'buffsize', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD | DWORD), DEFAULT VALUE= 0 (0 bytes).</b>
//<br><br>
//Returns the current capacity (in bytes) of the ppp. object's buffer.
//<br><br>
//Buffer capacity can be changed through the ppp.buffrq method followed by the sys.buffalloc method invocation.
//<br><br>
//The PPP object will be unable to operate properly if its buffer has inadequate capacity. Recommended buffer size is 5 pages.
//--------------------------------------------------------------------
Object.defineProperty(ppp, 'ip', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (STRING), DEFAULT VALUE= "1.0.0.1". </b><br><br>
//Sets/returns the IP address of the PPP interface of your device. <br><br>
//<br><br>
//Typically, the IP address of the PPP interface is negotiated with the ISP. Available GPRS library implements all necessary steps of PPP link negotiation for GPRS modems.
//<br><br>
//This property can only be written to when the PPP interface is disabled (ppp.enabled= 0- NO).
//**************************************************************************************************
//       ROM (ROM file access) object
//**************************************************************************************************
//The romfile object allows you to access resource (fixed) files that you have added to your project.
//Resource files appear under the "Resource Files" branch of your project tree.
//Resource files are not processed by the compiler in any way, they are just added to the compiled project binary "as is".
//<br><br>
//Resource files are ideal for storing permanent data that never changes.
//--------------------------------------------------------------------
romfile.find = function (frompos, substr, num) {
    if (romfile.currentFile === undefined || romfile.files[romfile.currentFile] === undefined) {
        return 255;
    }
    let count = 0;
    let cindex = 0;
    let index = 0;
    const fromposReal = frompos - 1;
    while (count < num) {
        cindex = romfile.files[romfile.currentFile].indexOf(substr, fromposReal);
        if (cindex === -1) {
            return 0;
        }
        count++;
    }
    return cindex + 1;
};
//<b>METHOD. [LEGACY]</b><br><br> 
//Locates the Nth occurrence of a substring within the currently opened resource file. <b>Will not work correctly for files exceeding 64K bytes.</b>
//<br><br>
//Returns a <i>16-bit </i>value indicating the file position at which the specified occurrence of the substring was found or 0 if the specified occurrence wasn't found.
//<b>The output is truncated to 16 bits. This is why this method will only work for files not exceeding 64K bytes.</b>
//<br><br>
//For this method to work, a resource file must first be successfully opened with romfile.open.
//<br><br>
//<b>Frompos </b>-- starting search position in the file. File positions are counted from 1.
//<br><br>
//<b>Substr </b>-- substring to search for.
//<br><br>
//<b>Num </b>-- substring occurrence to search for.
//<br><br>
//This method was preserved for compatibility with previously developed applications. You are recommended to use romfile.find32 -- it has no file size limitations. 
//--------------------------------------------------------------------
romfile.find32 = function (frompos, substr, num) { };
//<b>METHOD. </b><br><br> 
//Locates the Nth occurrence of a substring within the currently opened resource file.
//<br><br>
//Returns a <i>32-bit </i>value indicating the file position at which the specified occurrence of the substring was found or 0 if the specified occurrence wasn't found.
//<br><br>
//For this method to work, a resource file must first be successfully opened with romfile.open.
//<br><br>
//<b>Frompos </b>-- starting search position in the file. File positions are counted from 1.
//<br><br>
//<b>Substr </b>-- substring to search for.
//<br><br>
//<b>Num </b>-- substring occurrence to search for.
//--------------------------------------------------------------------
romfile.getdata = function (maxinplen) {
    if (romfile.currentFile === undefined || romfile.files[romfile.currentFile] === undefined) {
        return "";
    }
    const retStr = romfile.files[romfile.currentFile].substr(romfile.currentPointer - 1, maxinplen);
    romfile.currentPointer += maxinplen;
    return retStr;
};
//<b>METHOD. </b><br><br> 
//Reads the specified amount of bytes (characters) from the currently opened resource file, from the location pointed at by the file pointer (romfile.pointer32).
//<br><br>
//Returns a string containing a part of the resource file's data.
//<br><br>
//For this method to work, a resource file must first be successfully opened with romfile.open.
//<br><br>
//Invoking this method moves the current pointer position forward by the actual number of bytes read.
//<br><br>
//<b>Maxinplen </b>-- maximum number of characters to read from the file.
//The length of the returned string is also limited by two other factors: the receiving string capacity, and the amount of remaining data in the file (romfile.size+1-romfile.pointer).
//--------------------------------------------------------------------
Object.defineProperty(romfile, 'offset', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (DWORD)</b>.
//<br><br>
//For the currently opened resource file returns the absolute file offset of this file in the compiled project binary.
//<br><br>
//For this property to return meaningful data, a resource file must first be successfully opened with romfile.open.
//--------------------------------------------------------------------
romfile.open = function (filename) {
    if (romfile.files[filename] == undefined) {
        romfile.files[filename] = '';
    }
    romfile.currentPointer = 1;
    romfile.currentFile = filename;
};
//<b>METHOD. </b><br><br> 
//Opens or re-opens a resource file.
//<br><br>
//After the file is successfully opened (or re-opened), romfile.offset and romfile.size will start to return meaningful values.
//In addition, the file pointer (romfile.pointer, romfile.pointer32) will be set to 1.
//It will also become possible to use romfile.find, romfile.find32, and romfile.getdata methods.
//<br><br>
//<b>Filename </b>-- name of the resource file to open. Files that can be opened with this method are those appearing under the "Resource Files" branch of your project tree. 
//<br><br>
//There is no method (or need) to explicitly close resource files. Only one resource file can be opened at any given time.
//--------------------------------------------------------------------
Object.defineProperty(romfile, 'pointer', {
    get() { return romfile.currentPointer; },
    set(pos) {
        romfile.currentPointer = Number(pos);
    }
});
//<b>PROPERTY (WORD) [LEGACY]. </b><br><br>
//Sets/returns the current pointer position in the currently opened resource file. <b>Will not work correctly for files exceeding 64K bytes.</b>
//<br><br>
//If no file is opened, the file is empty, or the file opening fails (because the file with the specified name does not exist), the pointer is set to 0.
//For successfully opened non-empty resource files, the pointer value range is from 1 (first file position) to romfile.size+1 (past the last file position).
//<br><br>
//For this property to work, a non-empty resource file must first be successfully opened with romfile.open.
//<br><br>
//When a non-empty file is (re)opened with the romfile.open method, the pointer is reset to the first character of the file (position 1).
//<br><br>
//When you read from the file with romfile.getdata, the pointer is automatically moved forward by the number of bytes (characters) that have been read out.
//<br><br>
//This method was preserved for compatibility with previously developed applications. You are recommended to use romfile.pointer32 -- it has no file size limitations.
//--------------------------------------------------------------------
Object.defineProperty(romfile, 'pointer32', {
    get() { return romfile.currentPointer; },
    set(pos) {
        romfile.currentPointer = Number(pos);
    }
});
//<b>PROPERTY (DWORD). </b><br><br>
//Sets/returns the current pointer position in the currently opened resource file.
//<br><br>
//If no file is opened, the file is empty, or the file opening fails (because the file with the specified name does not exist), the pointer is set to 0.
//For successfully opened non-empty resource files, the pointer value range is from 1 (first file position) to romfile.size+1 (past the last file position).
//<br><br>
//For this property to work, a non-empty resource file must first be successfully opened with romfile.open.
//<br><br>
//When a non-empty file is (re)opened with the romfile.open method, the pointer is reset to the first character of the file (position 1).
//<br><br>
//When you read from the file with romfile.getdata, the pointer is automatically moved forward by the number of bytes (characters) that have been read out.
//--------------------------------------------------------------------
Object.defineProperty(romfile, 'size', {
    get() {
        if (romfile.currentFile === undefined) {
            return 0;
        }
        if (romfile.files[romfile.currentFile] === undefined) {
            return 0;
        }
        return romfile.files[romfile.currentFile].length;
    },
    set() { }
});
//<b>R/O PROPERTY (DWORD). </b><br><br>
//Returns the size of the currently opened resource file.
//<br><br>
//Zero size is returned if no file is opened of the file opening fails (because the file with the specified name does not exist). 
//<br><br>
//For this property to return meaningful data, a resource file must first be successfully opened with romfile.open.
//**************************************************************************************************
//       SER (Serial port) object
//**************************************************************************************************
//This is a serial port object that encompasses ALL serial ports (UARTs) available on a particular system (total number
//of available serial ports can be obtained through the <font color="maroon"><b>ser.numofports </b></font>read-only property).
//<br><br>
//Selection of a particular port to work with is done through the <font color="maroon"><b>ser.num property</b></font>. Most other 
//properties and methods refer to the currently selected port. When the handler for one of the serial port events is entered
//the <font color="maroon"><b>ser.num </b></font>is automatically switched to the port for which this event was generated.
//<br><br>
//Each serial port has 2 outputs- TX/W1out/dout and RTS/W0out/cout, and two inputs- RX/W1in/din and CTS/W0&1in/cin. Two lines- 
//TX/W1out/dout and RX/W1in/din use fixed I/O pins and cannot be remapped. Two other lines- RTS/W0out/cout and CTS/W0&1in/cin- can be 
//remapped through <font color="maroon"><b>ser.rtsmap </b></font>and <font color="maroon"><b>ser.ctsmap </b></font>properties.
//<br><br>
//The serial port can work in the UART, Wiegand, or clock/data mode (see <font color="maroon"><b>ser.mode</b></font>).
//<br><br>
//<b>Platforms with explicit configuration of I/O lines as inputs or outputs:</b>
//<br><br>
//For the Wiegand and clock/data mode, TX/W1out/dout and RTS/W0out/cout must be configured as outputs by the application (through <font color="maroon"><b>
//io.enabled</b></font>)- this won't happen automatically. The RX/W1in/din and CTS/W0&1in/cin lines must be configured as inputs- this 
//won't happen automatically as well. <br><br>For the UART mode, the TX/W1out/dout and RX/W1in/din are configured automatically when 
//the port is opened (see <font color="maroon"><b>ser.enabled</b></font>). Your application still needs to set the direction of 
//RTS/W0out/cout CTS/W0&1in/cin "manually".
//--------------------------------------------------------------------
Object.defineProperty(ser, 'numofports', {
    get() { return 0; },
    set() { }
});
//<b>READ-ONLY PROPERTY (BYTE). </b><br><br> 
//Returns total number of serial ports found on the current platform.
//--------------------------------------------------------------------
Object.defineProperty(ser, 'num', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (BYTE), DEFAULT VALUE= 0 (serial port #0 selected). </b><br><br>
//Sets/returns the number of currently selected serial port (ports are enumerated from 0).
//Most other properties and methods of this object relate to the serial port selected through this property.<br><br>
//Note that serial-port related events such as <font color="teal"><b>on_ser_data_arrival </b></font> change currently selected port!
//The value of this property won't exceed <font color="maroon"><b>ser.numofports</b></font>-1 (even if you attempt to set a higher value).
//--------------------------------------------------------------------
Object.defineProperty(ser, 'enabled', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE= <font color="olive"><b>0- NO</b></font> (not enabled). </b><br><br>
//Enables/disables currently selected serial port (selection is made through <font color="maroon"><b>ser.num</b></font>): 
//<font color="olive"><b>0- NO </b></font>(not enabled), <font color="olive"><b>1- YES </b></font>(enabled).<br><br>
//Enabling/disabling the serial port does not automatically clear its buffers, this is done via <font color="maroon"><b>ser.rxclear </b></font>
//and <font color="maroon"><b>ser.txclear</b></font>. <br><br>
//Notice that certain properties can only be changed and methods executed when the port is not enabled (<font color="maroon"><b>ser.rtsmap</b>
//</font>, <font color="maroon"><b>ser.ctsmap</b></font>, <font color="maroon"><b>ser.mode</b></font>, <font color="maroon"><b>ser.redir</b>
//</font>, <font color="maroon"><b>ser.txclear</b></font>). You also cannot allocate buffer memory for the port (do <font color="maroon"><b>
//sys.buffalloc </b></font>) when the port is enabled.
//--------------------------------------------------------------------
//<b>ENUM. </b><br><br> 
//Contains the list of constants related to the selection of the operating mode of the serial port.
//<b>PLATFORM CONSTANT (DEFAULT). </b><br><br> 
//UART mode, suitable for RS232, RS422, RS485, etc. communications in full-duplex or half-duplex mode 
//(see <font color="maroon"><b>ser.interface</b></font>).<br><br>
//Data is transmitted through the TX pin and received through the RX pin. Optionally, RTS (output) and CTS 
//(input) lines are used for flow control (see <font color="maroon"><b>ser.flowcontrol</b></font>) 
//in the full-duplex mode. Additionally, RTS can be used for direction control in the half-duplex mode.
//<b>PLATFORM CONSTANT. </b><br><br> 
//Wiegand mode, suitable for sending to or receiving data from any standard Wiegand device. Data transmission 
//is through pins W0out and W1out, reception- through W0&1in and W1in. <br><br>
//"W0&1in" means that a logical AND of W0 and W1 signals must be applied to this input. Therefore, external 
//logical gate is needed in order to receive Wiegand data.               
//<b>PLATFORM CONSTANT. </b><br><br> 
//Clock/data mode, suitable for sending to or receiving data from any standard clock/data (or magstripe) device.
//Data transmission is through pins cout and dout, reception- through cin and din. <br><br>
//Third line of the magstripe interface- card present- is not required for data reception. For transmission, 
//any I/O line can be used as card present output (under software control).
Object.defineProperty(ser, 'mode', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0- UART (UART). </b><br><br>
//Sets operating mode for the currently selected serial port (selection is made through <font color="maroon"><b>ser.num</b></font>): 
//<font color="olive"><b>0- PL_SER_MODE_UART </b></font>(UART), <font color="olive"><b>1- PL_SER_MODE_WIEGAND </b></font>(Wiegand), 
//<font color="olive"><b>2- PL_SER_MODE_CLOCKDATA </b></font>(clock/data). <br><br>
//Changing port mode is only possible when the port is closed (<font color="maroon"><b>ser.enabled</b></font>= <font color="olive"><b>
//0- NO</b></font>). RTS/W1out/cout and CTS/W0&1in/cin lines can be remapped to other I/O pins of the device through the <font color="maroon"><b>
//ser.rtsmap </b></font>and <font color="maroon"><b>ser.ctsmap </b></font>properties.
//<br><br>
//<b>Platforms with explicit configuration of I/O lines as inputs or outputs:</b>
//<br><br>
//For the UART mode (and provided that <font color="maroon"><b>ser.flowcontrol</b></font>= <font color="olive"><b>1- ENABLED</b></font>),
//you will need to configure RTS line as output and CTS line as input through the <font color="maroon"><b>io.enabled </b></font>property. 
//TX and RX configuration will happen automatically. <br><br>
//For the Wiegand and clock/data mode, you will need to configure both RTS and TX as outputs, and CTS and RX as inputs.  
//--------------------------------------------------------------------
//<b>ENUM. </b><br><br> 
//Contains the list of constants related to the selection of full-duplex or half-duplex interface for the UART mode
//of serial port (<font color="maroon"><b>ser.mode</b></font>= <font color="olive"><b>0- PL_SER_MODE_UART</b></font>).
//<b>PLATFORM CONSTANT (DEFAULT). </b><br><br> 
//Full-duplex mode, suitable for RS232, RS422, or four-wire RS485 communications. RTS output (together with 
//CTS input) can be used for optional hardware flow control (see <font color="maroon"><b>ser.flowcontrol</b></font>).
//<b>PLATFORM CONSTANT. </b><br><br> 
//Half-duplex mode, suitable for two-wire RS485 communications. RTS line is used for direction control.
//Direction control polarity can be set through <font color="maroon"><b>ser.dircontrol </b></font>property.
Object.defineProperty(ser, 'interface', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0- PL_SER_SI_FULLDUPLEX (full-duplex). </b><br><br>
//Chooses full-duplex or half-duplex operating mode for currently selected serial port (selection is made through <font color="maroon"><b>
//ser.num</b></font>): <font color="olive"><b>0- PL_SER_SI_FULLDUPLEX </b></font>(full-duplex mode), <font color="olive"><b>
//1- PL_SER_SI_HALFDUPLEX </b></font>(half-duplex mode). <br><br>
//Full-duplex mode is suitable for RS232, RS422, or four-wire RS485 communications. Half-duplex mode is suitable for 2-wire RS485 communications.
//This property is only relevant when the port is in the UART mode (<font color="maroon"><b>ser.mode</b></font>= <font color="olive"><b>
//0- PL_SER_MODE_UART</b></font>). <br><br>
//RTS and CTS lines can be remapped to other I/O pins of the device through the <font color="maroon"><b>ser.rtsmap </b></font>and 
//<font color="maroon"><b>ser.ctsmap </b></font>properties.
//<br><br>
//<b>Platforms with explicit configuration of I/O lines as inputs or outputs:</b>
//<br><br>
//You have to configure RTS line as output and CTS line as input 
//through the <font color="maroon"><b>io.enabled </b></font>property.
//--------------------------------------------------------------------
//<b>ENUM. </b><br><br> 
//Contains the list of constants related to the flow control for the UART mode of serial port (ser.mode= 0- PL_SER_MODE_UART).
//<b>PLATFORM CONSTANT (DEFAULT). </b><br><br> 
//No flow control.
//<b>PLATFORM CONSTANT. </b><br><br> 
//RTS/CTS flow control.
//<b>PLATFORM CONSTANT. </b><br><br> 
//XON/XOFF flow control.
Object.defineProperty(ser, 'flowcontrol', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0- DISABLED. </b><br><br> 
//Sets/returns flow control mode for currently selected serial port (selection is made through <font color="maroon"><b>ser.num</b></font>): 
//<font color="olive"><b>0- DISABLED</b></font>, <font color="olive"><b>1- PL_SER_FC_RTSCTS</b></font>, or <font color="olive"><b>1- PL_SER_FC_XONXOFF</b></font>. Only relevant when the serial port is in UART 
//mode (<font color="maroon"><b>ser.mode</b></font>= <font color="olive"><b>0- PL_SER_MODE_UART</b></font>) and full-duplex interface is selected 
//(<font color="maroon"><b>ser.interface</b></font>= <font color="olive"><b>0- PL_SER_SI_FULLDUPLEX</b></font>).<br><br>
//RTS/CTS flow control uses two serial port lines- RTS and CTS- to regulate the flow of data between the serial port of your device and another 
//("attached") serial device. On some platforms you can select which I/O line will serve as RTS line and which- as CTS line (see 
//<font color="maroon"><b>ser.rtsmap </b></font>and <font color="maroon"><b>ser.ctsmap</b></font>).
//XON/XOFF flow control uses XON (ser.xonchar) and XOFF (ser.xoffchar) characters to pause and resume transmission between devices.
//<br><br>
//<b>Platforms with explicit configuration of I/O lines as inputs or outputs:</b>
//<br><br>
//The RTS lines are not automatically configured as outputs and CTS- as inputs. You need to do this manually, through 
//the <font color="maroon"><b>io.enabled </b></font>property of the io object. 
//--------------------------------------------------------------------
Object.defineProperty(ser, 'rtsmap', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE- different for each serial port: UART0: 0- PL_IO_NUM_0, <br>
//UART1: 1- PL_IO_NUM_1,<br> UART2: 2- PL_IO_NUM_2, <br> UART3: 3- PL_IO_NUM_3. </b><br><br>
//Sets/returns the number of the I/O line that will act as RTS/W0out/cout output of currently selected serial port (selection is made through 
//<font color="maroon"><b>ser.num</b></font>). When the port in in the UART/full-duplex mode (<font color="maroon"><b>ser.mode </b></font>= 
//<font color="olive"><b>0- PL_SER_MODE_UART </b></font>and <font color="maroon"><b>ser.interface </b></font>= <font color="olive"><b>
//0- PL_SER_SI_FULLDUPLEX</b></font>) and the flow control is set to <font color="maroon"><b>ser.flowcontrol </b></font>=
//<font color="olive"><b>1- PL_SER_FC_RTSCTS</b></font>) the line will act as an RTS output, used for flow control. <br><br>
//In the UART/half-duplex mode (<font color="maroon"><b>ser.mode </b></font>= <font color="olive"><b>0- PL_SER_MODE_UART </b></font>and
//<font color="maroon"><b>ser.interface </b></font>= <font color="olive"><b>1- PL_SER_SI_HALFDUPLEX</b></font>) this line acts as direction 
//control output (see also <font color="maroon"><b>ser.dircontrol</b></font>). <br><br>
//In the UART mode, this line has no function when the port is configured for full-duplex operation and the flow control is disabled. When the 
//port is in the Wiegand mode (<font color="maroon"><b>ser.mode </b></font>= <font color="olive"><b>1- PL_SER_MODE_WIEGAND</b></font>) the line 
//will act as a W0out output of Wiegand interface. When the port is in the clock/data mode (<font color="maroon"><b>ser.mode </b></font>= 
//<font color="olive"><b>2- PL_SER_MODE_CLOCKDATA</b></font>) the line will act as a clock output of the clock/data interface. <br><br>
//Absolutely any I/O line can be selected by this property, as long as this line is not occupied by some other function. Property value can only 
//be changed when the port is closed (<font color="maroon"><b>ser.enabled </b></font>= <font color="olive"><b>0- NO</b></font>).
//<br><br>
//<b>Platforms with explicit configuration of I/O lines as inputs or outputs:</b>
//<br><br>
//For the selected line to work, you have to configure it as an output through the <font color="maroon"><b>io.enabled </b></font>property of the 
//io object.
//--------------------------------------------------------------------
Object.defineProperty(ser, 'ctsmap', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE- different for each serial port: UART0: 0- PL_INT_NUM_0, <br>
//UART1: 1- PL_INT_NUM_1, <br>UART2: 2- PL_INT_NUM_2, <br>UART3: 3- PL_INT_NUM_3. </b><br><br>
//Sets/returns the number of I/O line that will act as CTS/W0&1in/cin input of currently selected serial port (selection is made through 
//<font color="maroon"><b>ser.num</b></font>). When the port in in the UART mode (<font color="maroon"><b>ser.mode </b></font>= 
//<font color="olive"><b>0- PL_SER_MODE_UART</b></font>) and the flow control is set to ser.flowcontrol </b></font>= 1- PL_SER_FC_RTSCTS</b></font>) 
//the line will act as a CTS input, used for flow control.<br><br>
//When the port is in the Wiegand mode (<font color="maroon"><b>ser.mode </b></font>= <font color="olive"><b>1- PL_SER_MODE_WIEGAND</b></font>) 
//the line will act as a W0in input of Wiegand interface. <br><br>
//When the port is in the clock/data mode (<font color="maroon"><b>ser.mode </b></font>= <font color="olive"><b>2- PL_SER_MODE_CLOCKDATA</b>
//</font>) the line will act as a clock input of the clock/data interface.<br><br>
//Selection can be made only among interrupt lines 0-7 (that is, I/O lines 16-23). Regular, non-interrupt I/O lines cannot be selected. Property 
//value can only be changed when the port is closed (<font color="maroon"><b>ser.enabled </b></font>=<font color="olive"><b>0- NO</b></font>).
//<br><br>
//<b>Platforms with explicit configuration of I/O lines as inputs or outputs:</b>
//<br><br>
//For the selected line to work, you have to configure it as an input through the <font color="maroon"><b>io.enabled </b></font>
//property of the io object.
//--------------------------------------------------------------------
Object.defineProperty(ser, 'xonchar', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (BYTE), DEFAULT VALUE= &h11 (XON character) </b><br><br>
//Sets/returns the ASCII code of the character that will be used to PAUSE transmission in the XON/XOFF flow control mode (ser.flowcontrol= 2- PL_SER_FC_XONOFF)
//for the currently selected serial port (selection is made through ser.num).
//--------------------------------------------------------------------
Object.defineProperty(ser, 'xoffchar', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (BYTE), DEFAULT VALUE= &h13 (XOFF character) </b><br><br>
//Sets/returns the ASCII code of the character that will be used to RESUME transmission in the XON/XOFF flow control mode (ser.flowcontrol= 2- PL_SER_FC_XONOFF)
//for the currently selected serial port (selection is made through ser.num).
//--------------------------------------------------------------------
//<b>ENUM. </b><br><br> 
//Contains the list of constants related to the selection of polarity for the RTS line which controls direction in the UART/half-duplex mode of 
//the serial port (<font color="maroon"><b>ser.mode </b></font>= <font color="olive"><b>0- PL_SER_MODE_UART </b></font>and <font color="maroon">
//<b>ser.interface </b></font>= <font color="olive"><b>0- PL_SER_SI_FULLDUPLEX</b></font>).
//<b>PLATFORM CONSTANT (DEFAULT). </b><br><br> 
//Specifies (for UART/half-duplex mode of the serial port) that the RTS output will be LOW when the serial 
//port is ready to RX data and HIGH when the serial port is TXing data. LOW/HIGH states provided are for 
//the TTL serial ports of MODULE-level products, for RS232 these states will be in reverse.
//<b>PLATFORM CONSTANT. </b><br><br> 
//Specifies (for UART/half-duplex mode of the serial port) that the RTS output will be HIGH when the serial 
//port is ready to RX data and LOW when the serial port is TXing data. LOW/HIGH states provided are for 
//the TTL serial ports of MODULE-level products, for RS232 these states will be in reverse.
Object.defineProperty(ser, 'dircontrol', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0- PL_SER_DCP_LOWFORINPUT (LOW for input). </b><br><br>
//Sets/returns the polarity of the direction control line (RTS) for selected serial port (selection is made through <font color="maroon">
//<b>ser.num</b></font>): <br> <font color="olive"><b>0- PL_SER_DCP_LOWFORINPUT </b></font>(DIR LOW for input, HIGH for output),<br> 
//<font color="olive"><b>1- PL_SER_DCP_HIGHFORINPUT </b></font>(DIR HIGH for input, LOW for output). <br><br>
//Which I/O line of the device will be used  as RTS line is defined by the <font color="maroon"><b>ser.rtsmap </b></font>property. 
//Direction control is only relevant when the serial port is in the UART/half-duplex mode (<font color="maroon"><b>ser.mode </b></font>
//= <font color="olive"><b>0- PL_SER_MODE_UART </b></font>and <font color="maroon"><b>ser.interface </b></font>= <font color="olive"><b>
//1- PL_SER_SI_HALFDUPLEX</b></font>).<br><br>
//Note, that HIGH/LOW states specified above are for the TTL-serial interface of the MODULE-level products. If you are dealing with the RS232 
//port then the states will be in reverse (for example, <font color="olive"><b>1- PL_SER_DCP_HIGHFORINPUT </b></font>will mean "LOW for input, 
//HIGH for output"). When the serial port is in the UART/half-duplex mode you can use the CTS line as a regular I/O line of your device.
//--------------------------------------------------------------------
Object.defineProperty(ser, 'baudrate', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (WORD), DEFAULT VALUE= "platform-dependent, results in 9600 bps". </b><br><br>
//Sets/returns the baudrate "divisor value" for the selected serial port (selection is made through <font color="maroon"><b>ser.num</b></font>).
//Actual baudrade is calculated as follows: (9600*<font color="maroon"><b>ser.div9600</b></font>)/<font color="maroon"><b>ser.baudrate</b></font>.
//<br><br> 
//The <font color="maroon"><b>ser.div9600 </b></font>read-only property returns the value <font color="maroon"><b>ser.baudrate </b></font>must 
//be set to in order to obtain 9600 bps on a particular device under present operating confitions. This property is only relevant when the 
//serial port is in the UART mode (<font color="maroon"><b>ser.mode </b></font>= <font color="olive"><b>0- PL_SER_MODE_UART</b></font>).
//--------------------------------------------------------------------
//--------------------------------------------------------------------
//<b>ENUM. </b><br><br> 
//Contains the list of constants related to the selection of the parity mode of the serial port in the UART mode
//(<font color="maroon"><b>ser.mode </b></font>= <font color="olive"><b>0- PL_SER_MODE_UART</b></font>).
//<b>PLATFORM CONSTANT (DEFAULT). </b><br><br> No parity bit to be transmitted.
//<b>PLATFORM CONSTANT. </b><br><br> Even parity.
//<b>PLATFORM CONSTANT. </b><br><br> Odd parity.
//<b>PLATFORM CONSTANT. </b><br><br> Parity bit always at "1". Also can be used to emulate second stop bit
//(there is no separate property to explicitely select the number of stop bits).
//<b>PLATFORM CONSTANT. </b><br><br> Parity bit always at "0".
Object.defineProperty(ser, 'parity', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0- PL_SER_PR_NONE (no parity). </b><br><br>
//Sets/returns the parity mode for the selected serial port (selection is made through ser.num): 0- PL_SER_PR_NONE (no parity),
//1- PL_SER_PR_EVEN (even parity), 2- PL_SER_PR_ODD (odd parity), 3- PL_SER_PR_MARK (mark), 4- PL_SER_PR_SPACE (space).
//<br><br>
//Mark parity is equivalent to having a second stop-bit (there is no separate property to explicitly select the number of stop bits).
//<br><br>
//This property is only relevant when the serial port is in the UART mode (ser.mode= 0- PL_SER_MODE_UART).
//<br><br>
//<b>On the platform, the combination of 7 bits/word (ser.bits=0- PL_SER_BB_7) and ser.parity= 0- PL_SER_PR_NONE will NOT work correctly.</b>
//--------------------------------------------------------------------
//<b>ENUM. </b><br><br> 
//Contains the list of constants related to the selection of the number of bits in the word TXed/RXed by the serial
//port in the UART mode (<font color="maroon"><b>ser.mode</b></font>= <font color="olive"><b>0- PL_SER_MODE_UART</b></font>).
//<b>PLATFORM CONSTANT. </b><br><br> Data word TXed/RXed by the serial port is to contain 7 data bits.
//<b>PLATFORM CONSTANT (DEFAULT). </b><br><br> Data word TXed/RXed by the serial port is to contain 8 data bits.
Object.defineProperty(ser, 'bits', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE= 1- PL_SER_BB_8 (8 bits). </b><br><br>
//Specifies the number of data bits in a word TXed/RXed by the currently selected serial port (selection is made through ser.num):
//<br>0- PL_SER_BB_7 (7 bits/word), or 1- PL_SER_BB_8 (8 bits/word).
//<br><br>
//This property is only relevant when the serial port is in the UART mode (ser.mode = 0- PL_SER_MODE_UART).
//<br><br>
//<b>On the platform, the combination of 7 bits/word (ser.bits=0- PL_SER_BB_7) and ser.parity= 0- PL_SER_PR_NONE will NOT work correctly.</b>
//--------------------------------------------------------------------
Object.defineProperty(ser, 'interchardelay', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (BYTE), DEFAULT VALUE= 0 (no delay). </b><br><br>
//Sets/returns maximum intercharacter delay for the selected serial port (selection is made through <font color="maroon"><b>ser.num</b></font>) 
//in 10ms steps.<br><br>
//For UART mode (<font color="maroon"><b>ser.mode </b></font>= <font color="olive"><b>0- PL_SER_MODE_UART</b></font>) specifies the time that 
//needs to elapse since the arrival of the most recent serial character into the RX buffer to cause the data to be committed (and 
//<font color="teal"><b>on_ser_data_arrival </b></font>event generated). <br><br>
//For Wiegand and clock/data mode (<font color="maroon"><b>ser.mode </b></font>= <font color="olive"><b>1- PL_SER_MODE_WIEGAND </b></font>or 
//<font color="olive"><b>2- PL_SER_MODE_CLOCKDATA</b></font>) the time since the most recent data bit (high-to-low transition on the W0&1in/cin 
//line) is counted. <br><br>
//In the UART mode this property allows you to combine incoming serial data into larger "chunks", which typically improves performance. Notice, 
//that the time is not counted when the new data is not being received because the serial port has set the RTS line to LOW (not ready).<br><br>
//For this to happen, the serial port must be in the UART/full-duplex/flow control mode (<font color="maroon"><b>ser.mode </b></font>= 
//<font color="olive"><b>0- PL_SER_MODE_UART</b></font>, <font color="maroon"><b>ser.interface </b></font>= <font color="olive"><b>
//0- 0- PL_SER_SI_FULLDUPLEX</b></font>, and <font color="maroon"><b>ser.flowcontrol </b></font>= <font color="olive"><b>1- ENABLED</b></font>) 
//and the RX buffer must be getting nearly full (less than 64 bytes of free space left). <br><br>
//For Wiegand and clock/data modes, counting timeout  since the last bit is the only way to determine the end of the data output. Suggested 
//timeout is app. 10 times the bit period of the data output by attached Wiegand or clock/data device.
//--------------------------------------------------------------------
Object.defineProperty(ser, 'autoclose', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE= <font color="olive"><b>0- NO</b></font>. </b><br><br>
//For currently selected serial port (selection is made through <font color="maroon"><b>ser.num</b></font>) specifies whether the port will 
//be disabled (<font color="maroon"><b>ser.enabled </b></font>= <font color="olive"><b>0- NO</b></font>) once the intercharacter gap expires 
//(see <font color="maroon"><b>ser.interchardelay</b></font>): <br><br>
//<font color="olive"><b>0- NO </b></font>(port won't be closed),<br> <font color="olive"><b>1- YES </b></font>(port will be closed). <br><br>
//This property offers a way to make sure that no further data is received once the gap of certain length is encountered. This property is
//especially useful in Wiegand or clock/data mode (<font color="maroon"><b>ser.mode </b></font>= <font color="olive"><b>
//1- PL_SER_MODE_WIEGAND </b></font>or <font color="olive"><b>2- PL_SER_MODE_CLOCKDATA</b></font>) where intercharacter gap is the only way 
//to reliably identify the end of one data transmission.
//--------------------------------------------------------------------
//<b>ENUM. </b><br><br> 
//Contains the list of constants related to the selection of the escape sequence type for the the serial port when the
//port is in the UART mode (<font color="maroon"><b>ser.mode </b></font>= <font color="olive"><b>0- PL_SER_MODE_UART</b></font>).
//<b>PLATFORM CONSTANT. </b><br><br> Recognition of serial escape sequences disabled.
//<b>PLATFORM CONSTANT. </b><br><br> 
//Escape sequences of type1 are to be recognized. Type1 escape sequence is "prev_char<--min 100ms-->EC<--min 
//100ms-->EC<--min 100ms-->EC", where "EC" is escape character defined by the <font color="maroon"><b>
//ser.escchar </b></font>property.<br><br>
//There must be at least 100ms gap before the arrival of each escape character, otherwise the character will be 
//counted as a regular data character. When escape sequence is detected in the incoming UART data stream the 
//<font color="teal"><b>on_ser_esc </b></font>event is generated and the serial port is disabled, 
//i.e. <font color="maroon"><b>ser.enabled </b></font>= <font color="olive"><b>0- NO</b></font>. 
//<b>PLATFORM CONSTANT</b></font>. </b><br><br> 
//Escape sequences of type2 are to be recognized. Type2 escape sequence is "EC OC", where "EC" is escape 
//character defined by the <font color="maroon"><b>ser.escchar </b></font>property and "OC" is any character other
//than "EC".<br><br>
//When escape sequence is detected in the incoming UART data stream the <font color="teal"><b>on_ser_esc
//</b></font>event is generated and the serial port is disabled, i.e. <font color="maroon"><b>ser.enabled 
//</b></font>= <font color="olive"><b>0- NO</b></font>.<br><br>
//Data character with ASCII code matching that of selected EC should be transmitted as "EC EC"- this will result 
//in a single character added to the RX buffer of the serial port.
Object.defineProperty(ser, 'esctype', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0- PL_SER_ET_DISABLED (escape sequences disabled).  </b><br><br>
//Defines, for selected serial port (selection is made through <font color="maroon"><b>ser.num</b></font>) whether serial escape sequence
//recognition is enabled and, if yes, what type of escape sequence is to be recognised. <br><br>
//Escape sequence is a special occurrence of characters in the incoming data received by the serial port. When escape sequence is detected the
//<font color="teal"><b>on_ser_esc</b></font> event is generated and the serial port is disabled (<font color="maroon"><b>
//ser.enabled </b></font>= <font color="olive"><b>0- NO</b></font>). When enabled, serial escape sequence detection works even when the buffer
//shorting is employed (see <font color="maroon"><b>ser.redir </b></font>property). <br><br>
//The <font color="maroon"><b>ser.esctype </b></font>property can have the following values: <br>  
//<font color="olive"><b>0- PL_SER_ET_DISABLED </b></font>(recognition of serial escape sequences disabled),<br><font color="olive">
//<b>1- PL_SER_ET_TYPE1</b></font> (Escape sequences of type1 are to be recognized),<br> <font color="olive"><b> 2- PL_SER_ET_TYPE2
//</b></font>(escape sequences of type2 are to be recognized).<br><br> 
//Type1 escape sequence is "prev_char<--min 100ms-->EC<--min 100ms-->EC<--min 100ms-->EC" and Type2 sequence is "EC OC", where "EC" is escape
//character defined by the <font color="maroon"><b>ser.escchar </b></font>property and "OC" is any character other than "EC".<br><br>
//This property is only relevant in the UART mode of the serial port (<font color="maroon"><b>ser.mode </b></font>= <font color="olive">
//<b>0- PL_SER_MODE_UART</b></font>).
//--------------------------------------------------------------------
Object.defineProperty(ser, 'escchar', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (BYTE), DEFAULT VALUE= 1 (SOH character).  </b><br><br>
//For selected serial port (selection is made through <font color="maroon"><b>ser.num</b></font>) sets/retrieves ASCII code of the escape
//character used for type1 or type2 serial escape sequences. <br><br>
//Which escape sequence is enabled is defined by the <font color="maroon"><b>ser.esctype </b></font>property. This property is irrelevant when
//<font color="maroon"><b>ser.esctype </b></font>= <font color="olive"><b>0- PL_SER_ET_DISABLED </b></font> (escape sequences disabled) or when
//the serial port is in the Wiegand or clock/data mode (<font color="maroon"><b>ser.mode </b></font>= <font color="olive"><b>
//1- PL_SER_MODE_WIEGAND </b></font> or <font color="maroon"><b>ser.mode </b></font>= <font color="olive"><b>2- PL_SER_MODE_CLOCKDATA</b></font>)
//-- serial escape sequences are only recognized in the UART data.
//--------------------------------------------------------------------
Object.defineProperty(ser, 'rxbuffsize', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD | DWORD), DEFAULT VALUE=0 (0 bytes). </b><br><br>
//For the selected serial port (selection is made through <font color="maroon"><b>ser.num</b></font>)returns current RX buffer capacity 
//in bytes. Buffer capacity can be changed through the <font color="maroon"><b>ser.rxbuffrq </b></font>method followed by the 
//<font color="maroon"><b>sys.buffalloc </b></font>method.<br><br>
//The <font color="maroon"><b>ser.rxbuffrq </b></font>requests buffer size in 256-byte pages whereas this property returns buffer size 
//in bytes. Relationship between the two is as follows: <br><br><font color="maroon"><b>ser.rxbuffsize</b></font>=num_pages*256-X (or =0 
//when num_pages=0), where "num_pages" is the number of buffer pages that was GRANTED through the <font color="maroon"><b>ser.rxbuffrq</b></font>.
// "-X" is because a number of bytes is needed for internal buffer
//variables. X=17 on 16-bit platforms and 33 on 32-bit platforms. <br><br>
//The serial port cannot RX data when the RX buffer has zero capacity.
//--------------------------------------------------------------------
Object.defineProperty(ser, 'txbuffsize', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD | DWORD), DEFAULT VALUE=0 (0 bytes). </b><br><br>
//For the selected serial port (selection is made through <font color="maroon"><b>ser.num</b></font>) returns current TX buffer capacity 
//in bytes. Buffer capacity can be changed through the <font color="maroon"><b>ser.txbuffrq </b></font>method followed by the 
//<font color="maroon"><b>sys.buffalloc </b></font>method. <br><br>
//The <font color="maroon"><b>ser.txbuffrq </b></font>requests buffer size in 256-byte pages whereas this property returns buffer size 
//in bytes. Relationship between the two is as follows: <br><br><font color="maroon"><b>ser.txbuffsize</b></font>=num_pages*256-X (or =0 
//when num_pages=0), where "num_pages" is the number of buffer pages that was GRANTED through the <font color="maroon"><b>ser.txbuffrq</b></font>. 
// "-X" is because a number of bytes is needed for internal buffer
//variables. X=17 on 16-bit platforms and 33 on 32-bit platforms.<br><br>
//The serial port cannot TX data when the TX buffer has zero capacity.
//--------------------------------------------------------------------
Object.defineProperty(ser, 'rxlen', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD | DWORD), DEFAULT VALUE=0 (0 bytes). </b><br><br>
//For the selected serial port (selection is made through <font color="maroon"><b>ser.num</b></font>) returns total number of committed bytes
//currently waiting in the RX buffer to be extracted and processed by your application. <br><br>
//The <font color="teal"><b>on_ser_data_arrival </b></font>event is generated once the RX buffer is not empty, i.e. there is data to
//process. There may be only one <font color="teal"><b>on_ser_data_arrival </b></font>event for each port waiting to be processed in 
//the event queue. Another <font color="teal"><b>on_ser_data_arrival </b></font> event for the same port may be generated only after
//the previous one is handled.<br><br>
//If, during the <font color="teal"><b>on_ser_data_arrival </b></font>event handler execution, not all data is extracted from the RX 
//buffer, another <font color="teal"><b>on_ser_data_arrival </b></font>event is generated immediately after the 
//<font color="teal"><b>on_ser_data_arrival </b></font>event handler is exited.<br><br>
//Notice that the RX buffer of the serial port employes "data committing" based on the amount of data in the buffer and intercharacter delay 
//(<font color="maroon"><b>ser.interchardelay</b></font>). Data in the RX buffer may not be committed yet. Uncommitted data is not visible
//to your application and is not included in the count returned by the  <font color="maroon"><b>ser.rxlen</b></font>).
//--------------------------------------------------------------------
Object.defineProperty(ser, 'txlen', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD | DWORD), DEFAULT VALUE=0 (0 bytes). </b><br><br>
//For the selected serial port (selection is made through <font color="maroon"><b>ser.num</b></font>) returns total number of committed bytes
//currently found in the TX buffer. The data in the TX buffer does not become committed until you use the  <font color="maroon"><b>ser.send
//</b></font>) method. <br><br>
//Your application may use the <font color="maroon"><b>ser.notifysent </b></font>method to get <font color="teal"><b>
//on_ser_data_sent </b></font>event once the total number of committed bytes in the TX buffer drops below the level defined by the
//<font color="maroon"><b>ser.notifysent </b></font> method. <br><br>
//See also <font color="maroon"><b>ser.newtxlen</b></font>.
//--------------------------------------------------------------------
Object.defineProperty(ser, 'txfree', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD | DWORD), DEFAULT VALUE=0 (0 bytes). </b><br><br>
//For the selected serial port (selection is made through <font color="maroon"><b>ser.num </b></font>)returns the amount of free space in the TX
//buffer in bytes, not taking into account uncommitted data. <br><br>
//Actual free space is <font color="maroon"><b>ser.txfree</b></font> - <font color="maroon"><b>ser.newtxlen</b></font>. Your application will not
//be able to store more data than this amount.<br><br>
//To achieve asynchronous data processing, use the <font color="maroon"><b>ser.notifysent</b></font> method to get <font color="teal">
//<b>on_ser_data_sent </b></font>event once the TX buffer gains required amount of free space.
//--------------------------------------------------------------------
Object.defineProperty(ser, 'newtxlen', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD | DWORD), DEFAULT VALUE=0 (0 bytes). </b><br><br>
//For the selected serial port (selection is made through <font color="maroon"><b>ser.num</b></font>) returns the amount of uncommitted TX data
//in bytes.<br><br>
//Uncommited data is the one that was added to the TX buffer with the <font color="maroon"><b>ser.setdata </b></font>method but not yet committed
//using the <font color="maroon"><b>ser.send</b></font>) method.
//--------------------------------------------------------------------
ser.rxclear = function () { };
//<b>METHOD. </b><br><br>
//For the selected serial port (selection is made through <font color="maroon"><b>ser.num</b></font>) clears (deletes all data from) the RX
//buffer.
//--------------------------------------------------------------------
ser.txclear = function () { };
//<b>METHOD. </b><br><br>
//For the selected serial port (selection is made through <font color="maroon"><b>ser.num</b></font>) clears (deletes all data from) the TX 
//buffer. This method will only work when the serial port is closed (<font color="maroon"><b>ser.enabled</b></font>= <font color="olive"><b>
//0- NO</b></font>).
//--------------------------------------------------------------------
ser.getdata = function (maxinplen) { };
//<b>METHOD. </b><br><br>
//For the selected serial port (selection is made through <font color="maroon"><b>ser.num </b></font>) returns the string that contains the data
//extracted from the RX buffer. Extracted data is permanently deleted from the buffer.<br><br>
//Length of extracted data is limited by one of the three factors (whichever is smaller): amount of committed data in the RX buffer itself,
//capacity of the "receiving" string variable, and the limit set by the maxinplen argument.<br><br>
//In the UART mode (<font color="maroon"><b>ser.mode</b></font>= <font color="olive"><b>0- PL_SER_MODE_UART</b></font>)
//the data is extracted "as is". <br><br>
//For Wiegand and clock/data mode (<font color="maroon"><b>ser.mode</b></font>= <font color="olive"><b>1- PL_SER_MODE_WIEGAND</b></font> and
//<font color="maroon"><b>ser.mode</b></font>= <font color="olive"><b>2- PL_SER_MODE_CLOCKDATA</b></font>) each character of extracted data
//represents one data bit and only two characters are possible: "0" or "1".
//<br><br>
//See also <font color="maroon"><b>ser.peekdata </b></font>method.
//--------------------------------------------------------------------
ser.peekdata = function (maxinplen) { };
//METHOD.
//For the selected serial port (selection is made through <font color="maroon"><b>ser.num </b></font>) returns the string that contains the "preview" of the data
//from the RX buffer. The data is NOT deleted from the buffer. Length of returned data is limited by one of the three factors
//(whichever is smaller): amount of committed data in the RX buffer itself, capacity of the "receiving" string variable,
//and the limit set by the maxinplen argument.
//<br><br>
//String variables can hold up to 255 bytes of data, so this method will only
//allow you to preview up to 255 "next" bytes from the RX buffer.
//In the UART mode (<font color="maroon"><b>ser.mode</b></font>= <font color="olive"><b>0- PL_SER_MODE_UART</b></font>)
//the data is previed "as is".
//<br><br>
//For Wiegand and clock/data mode (<font color="maroon"><b>ser.mode</b></font>= <font color="olive"><b>1- PL_SER_MODE_WIEGAND</b></font> and
//<font color="maroon"><b>ser.mode</b></font>= <font color="olive"><b>2- PL_SER_MODE_CLOCKDATA</b></font>) each data character
//represents one data bit and only two characters are possible: "0" or "1".
//<br><br>
//See also <font color="maroon"><b>ser.getdata </b></font>method.
//--------------------------------------------------------------------
ser.setdata = function (txdata) { };
//<b>METHOD. </b><br><br>
//For the selected serial port (selection is made through <font color="maroon"><b>ser.num</b></font>) adds the data passed in the txdata argument
//to the contents of the TX buffer. <br><br>
//In the UART mode (<font color="maroon"><b>ser.mode</b></font>= <font color="olive"><b>0- PL_SER_MODE_UART</b></font>) the data is added "as is". 
//<br><br>For Wiegand and clock/data mode (<font color="maroon"><b>ser.mode</b></font>= <font color="olive"><b>1- PL_SER_MODE_WIEGAND </b></font>
//and <font color="maroon"><b>ser.mode</b></font>= <font color="olive"><b>2- PL_SER_MODE_CLOCKDATA</b></font>) each data character represents
//one data bit and only bit0 (least significant bit) of each character is relevant (therefore, adding "0101" will result in
//the 0101 sequence of data bits). <br><br>
//If the buffer doesn't have enough space to accommodate the data being added then this data will be truncated. Newly saved data is not sent out
//immediately. This only happens after the  <font color="maroon"><b>ser.send </b></font>) method is used to commit the data. This allows your
//application to prepare large amounts of data before sending it out.<br><br>
//Total amount of newly added (uncommitted) data in the buffer can be checked through the <font color="maroon"><b>ser.newtxlen</b></font>
//setting. <br><br>
//Also see <font color="maroon"><b>ser.txlen</b></font>, <font color="maroon"><b>ser.txfree</b></font>, <font color="maroon"><b>
//ser.notifysent</b></font>, and <font color="teal"><b>on_ser_data_sent</b></font>. 
//--------------------------------------------------------------------
ser.send = function () { };
//<b>METHOD. </b><br><br>
//For the selected serial port (selection is made through <font color="maroon"><b>ser.num</b></font>) commits (allows sending) the data that was
//previously saved into the TX buffer using the <font color="maroon"><b>ser.setdata</b></font> method.<br><br>
//You can monitor the sending progress by checking the <font color="maroon"><b>ser.txlen </b></font>property or using the 
//<font color="maroon"><b>ser.notifysent </b></font>method and the <font color="teal"><b>on_ser_data_sent </b></font>event. 
//--------------------------------------------------------------------
ser.notifysent = function (threshold) { };
//<b>METHOD. </b><br><br>
//Using this method for the selected serial port (selection is made through <font color="maroon"><b>ser.num</b></font>) will cause the 
//<font color="teal"><b>on_ser_data_sent </b></font> event to be generated when the amount of committed data in the TX buffer is found 
//to be equal or below "threshold" number of bytes.<br><br>
//Only one <font color="teal"><b>on_ser_data_sent </b></font>event will be generated each time after the <font color="maroon"><b>
//ser.notifysent </b></font> is invoked. This method, together with the <font color="teal"><b>on_ser_data_sent </b></font>event 
//provides a way to handle data sending asynchronously. <br><br>
//Just like with <font color="maroon"><b>ser.txfree</b></font>, the trigger you set won't take into account any uncommitted data in the TX buffer.
//--------------------------------------------------------------------
ser.rxbuffrq = function (numpages) { };
//<b>METHOD. </b><br><br>
//For the selected serial port (selection is made through <font color="maroon"><b>ser.num </b></font>) pre-requests "numpages" number of 
//buffer pages (1 page= 256 bytes) for the RX buffer of the serial port. Returns actual number of pages that can be allocated.
//Actual allocation happens when the <font color="maroon"><b>sys.buffalloc </b></font> method is used. <br><br>
//The serial port is unable to RX data if its RX buffer has 0 capacity. Actual current buffer capacity can be checked through the
//<font color="maroon"><b>ser.rxbuffsize </b></font> which returns buffer capacity in bytes. <br><br>
//Relationship between the two is as follows: <font color="maroon"><b>ser.rxbuffsize</b></font>=num_pages*256-X (or =0 when num_pages=0), where
//"num_pages" is the number of buffer pages that was GRANTED through the <font color="maroon"><b>ser.rxbuffrq</b></font>. "-X" is because a number of bytes is needed for internal buffer
//variables. X=17 on 16-bit platforms and 33 on 32-bit platforms.<br><br>
//Buffer allocation will not work if the serial port to which this buffer belongs is opened (<font color="maroon"><b>ser.enabled</b></font>=
//<font color="olive"><b>1- YES</b></font>) at the time when <font color="maroon"><b>sys.buffalloc </b></font> executes. You can only change
//buffer sizes of ports that are closed.
//<br><br>
//<b>On the EM2000 and other 32-bit platforms, the maximum number of pages you can request for one buffer is limited to 255.</b>
//<br><br>
//See also <font color="maroon"><b>ser.txbuffrq </b></font>method.
//--------------------------------------------------------------------
ser.txbuffrq = function (numpages) { };
//<b>METHOD. </b><br><br>
//For the selected serial port (selection is made through <font color="maroon"><b>ser.num </b></font>) pre-requests "numpages" number of 
//buffer pages (1 page= 256 bytes) for the TX buffer of the serial port. Returns actual number of pages that can be allocated.
//Actual allocation happens when the <font color="maroon"><b>sys.buffalloc </b></font> method is used. <br><br>
//The serial port is unable to TX data if its TX buffer has 0 capacity. Actual current buffer capacity can be checked through the 
//<font color="maroon"><b>ser.txbuffsize </b></font> which returns buffer capacity in bytes.<br><br>
//Relationship between the two is as follows: <font color="maroon"><b>ser.txbuffsize</b></font>=num_pages*256-X (or =0 when num_pages=0), where
//"num_pages" is the number of buffer pages that was GRANTED through the <font color="maroon"><b>ser.txbuffrq</b></font>. "-X" is because a number of bytes is needed for internal buffer
//variables. X=17 on 16-bit platforms and 33 on 32-bit platforms.<br><br>
//Buffer allocation will not work if the serial port to which this buffer belongs is opened (<font color="maroon"><b>ser.enabled</b></font>= 
//<font color="olive"><b>1- YES</b></font>) at the time when <font color="maroon"><b>sys.buffalloc </b></font> executes. You can only change
//buffer sizes of ports that are closed.
//<br><br>
//<b>On the EM2000 and other 32-bit platforms, the maximum number of pages you can request for one buffer is limited to 255.</b>
//<br><br>
//See also <font color="maroon"><b>ser.rxbuffrq </b></font> method.
//--------------------------------------------------------------------
ser.redir = function (redir) { };
//<b>METHOD. </b><br><br>
//For the selected serial port (selection is made through <font color="maroon"><b>ser.num</b></font>) redirects the data being RXed to the TX
//buffer of the same serial port, different serial port, or another object that supports compatible buffers.<br><br>
//The redir argument, as well as the value returned by this method are of "enum <font color="olive"><b>pl_redir </b></font>" type. The
//<font color="olive"><b>pl_redir </b></font>defines a set of inter-object constants that include all possible redirections for this
//platform. Specifying redir value of <font color="olive"><b>0- PL_REDIR_NONE </b></font>cancels redirection. <br><br>
//When the redirection is enabled for a particular serial port, the <font color="teal"><b>on_ser_data_arrival</b></font>
//event is not generated for this port. If redirection is being done on the port that is currently opened (<font color="maroon"><b>
//ser.enabled</b></font>= <font color="olive"><b>1- YES</b></font>) then the port will be closed automatically. <br><br>
//This method returns actual redirection result: <font color="olive"><b>0- PL_REDIR_NONE </b></font>if redirection failed or the same value
//as the one that was passed in the redir argument if redirection was successful.
//--------------------------------------------------------------------
Object.defineProperty(ser, 'div9600', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD), DEFAULT VALUE= "platform dependent". </b><br><br>
//Returns the value to which the <font color="maroon"><b>ser.baudrate </b></font>property must be set in order to achieve the baudrate of 
//9600bps under present operating conditions. <br><br>
//This property will return a different value depending on the PLL mode of the device (see<font color="maroon"><b>sys.currentpll</b></font>).<br><br>
//"Smart" applications will use this property to set baudrates independently of present operating conditions.<br><br>
//The value may also differ between the serial ports on the same device. An example of such device is the EM2000. On this module, the ser.div9600 value for UART3 is different from the value for UARTS0~2.
//--------------------------------------------------------------------
Object.defineProperty(ser, 'sinkdata', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0- NO (normal data processing). </b><br><br>
//For the currently selected serial port (selection is made through <font color="maroon"><b>ser.num</b></font>)
//specifies whether the incoming data should be discarded.
//<br><br>
//Setting this property to
//<font color="olive"><b>1- YES </b></font>
//causes the port to automatically discard all incoming data without passing it to your application.
//<br><br>
//The <font color="teal"><b>on_ser_data_arrival </b></font>
//event will not be generated, reading
//<font color="maroon"><b>ser.rxlen </b></font>
//will always return zero, and so on. No data will be reaching its destination even in case of buffer redirection
//(see <font color="maroon"><b>ser.redir</b></font>).
//<br><br>
//Escape characters
//(see <font color="maroon"><b>ser.esctype </b></font>and <font color="maroon"><b>ser.escchar</b></font>)
//will still be detected in the incoming data stream.
//--------------------------------------------------------------------
//--------------------------------------------------------------------
//<b>EVENT of the ser object. </b><br><br> 
//Generated when currently enabled escape sequence is detected in the received UART data stream. Once the serial escape sequence is detected 
//on a certain serial port this port is automatically disabled (<font color="maroon"><b>ser.enabled</b></font>= <font color="olive"><b>
//0- NO</b></font>).
//<br><br>
//When event handler for this event is entered the <font color="maroon"><b>ser.num </b></font>
//property is automatically switched to the port
//on which this event was generated. Whether or not escape sequence detection is enabled and what kind of escape sequence is expected is
//defined by the
//<font color="maroon"><b>ser.esctype </b></font>property.
//<br><br>
//Escape sequence detection works even when buffer redirection is set for the serial port using the <font color="maroon"><b>ser.redir
//</b></font> method. Escape sequences are only recognized in the UART mode of the serial port (<font color="maroon"><b>ser.mode</b></font>
//= <font color="olive"><b>0- PL_SER_MODE_UART</b></font>).
//<br><br>
//Another <font color="teal"><b>on_ser_esc </b></font>
//event for a particular port is never generated until the previous one is processed.
//<br><br>
//--------------------------------------------------------------------
//<b>EVENT of the ser object. </b><br><br> Generated when at least one data byte is present in the RX buffer of the serial port (i.e. for this
//port the  <font color="maroon"><b>ser.rxlen</b></font>)>0). When the event handler for this event is entered the <font color="maroon"><b>
//ser.num </b></font>property is automatically switched to the port for which this event was generated. <br><br>
//Another <font color="teal"><b>on_ser_data_arrival </b></font>event on a particular port is never generated until the previous one is
//processed. Use <font color="maroon"><b>ser.getdata </b></font>method to extract the data from the RX buffer. <br><br>
//You don't have to process all  data in the RX buffer at once. If you exit the <font color="teal"><b>on_ser_data_arrival
//</b></font>event handler while there is still some unprocessed data in the RX buffer another <font color="teal"><b>on_ser_data_arrival
//</b></font>event will be generated immediately. <br><br>
//This event is not generated for a particular port when buffer redirection is set for this port through the <font color="maroon"><b>
//ser.redir</b></font> method.
//--------------------------------------------------------------------
//<b>EVENT of the ser object. </b><br><br> 
//Generated after the total amount of committed data in the TX buffer of the serial port (<font color="maroon"><b>ser.txlen</b></font>) is 
//found to be less than the threshold that was preset through the <font color="maroon"><b>ser.notifysent </b></font>method. <br><br>
//This event may be generated only after the <font color="maroon"><b>ser.notifysent </b></font>method was used. Your application needs to use
//the <font color="maroon"><b>ser.notifysent </b></font>method EACH TIME it wants to cause the <font color="teal"><b>on_ser_data_sent
//</b></font>event generation for a particular port. <br><br>
//When the event handler for this event is entered the <font color="maroon"><b>ser.num </b></font>is automatically switched to the port on
//which this event was generated. Please, remember that uncommitted data in the TX buffer is not taken into account for the 
//<font color="teal"><b>on_sock_data_sent </b></font>event generation.
//--------------------------------------------------------------------
//<b>EVENT of the ser object. </b><br><br> 
//Generated when data overrun has occurred in the RX buffer of the serial port.
//<br><br>
//Another <font color="teal"><b>on_ser_overrun </b></font>
//event for a particular port is never generated until the previous one is processed. <br><br>
//When the event handler for this event is entered the <font color="maroon"><b>ser.num </b></font>property is automatically switched to the
//port on which this event was generated. <br><br>
//Data overruns are a common occurrence on serial lines. The overrun happens when the serial data is arriving into the RX buffer faster than
//your application is able to extract it, the buffer runs out of space and "misses" some incoming data. <br><br>
//For UART/full-duplex mode of the serial port (<font color="maroon"><b>ser.mode</b></font>= <font color="olive"><b>0- PL_SER_MODE_UART
//</b></font> and <font color="maroon"><b>ser.interface</b></font>= <font color="olive"><b>0- PL_SER_SI_FULLDUPLEX</b></font>) data overruns
//can be prevented through the use of RTS/CTS flow control (see <font color="maroon"><b>ser.flowcontrol</b></font>).//**************************************************************************************************
//       SOCK (Socket) object
//**************************************************************************************************
//This is the sockets object that encompasses ALL available sockets. Total number of sockets is typically 16 but can be
//less due to memory limitations of a particular platform. The number of available sockets can be obtained through
//the <font color="maroon"><b>sock.numofsock </b></font> read-only property. <br><br>
//Selection of a particular socket to work with is done through the <font color="maroon"><b>sock.num </b></font>property. Most other 
//properties and methods refer to the currently selected socket. <br><br>
//When the handler for one of the socket events is entered the <font color="maroon"><b>sock.num  </b></font>is automatically switched 
//to the socket for which this event was generated.   
//--------------------------------------------------------------------
//<b>ENUM. </b><br><br> Contains the list of constants related to possible socket states. See also enum <font color="olive"><b>pl_sock_state_simple</b></font>.
//<b>PLATFORM CONSTANT. </b><br><br> Connection is closed (and haven't been opened yet, it is a
//post-powerup state). <br><br>Applies both to UDP and TCP.
//<b>PLATFORM CONSTANT. </b><br><br> Connection is closed (it was a passive close). <br><br>Applies only to TCP.
//<b>PLATFORM CONSTANT. </b><br><br> Connection is closed (it was an active close by the
//application). <br><br>Applies only to TCP.
//<b>PLATFORM CONSTANT. </b><br><br> Connection is closed (it was a passive reset during a
//passive open).<br><br> Applies only to TCP.
//<b>PLATFORM CONSTANT. </b><br><br> Connection is closed (it was a passive reset during an
//active open). <br><br>Applies only to TCP.
//<b>PLATFORM CONSTANT. </b><br><br> Connection is closed (it was a passive reset while in
//"connection established" state). <br><br>Applies only to TCP.
//<b>PLATFORM CONSTANT. </b><br><br> Connection is closed (it was a passive reset while performing
//a passive close). Applies only to TCP.
//<b>PLATFORM CONSTANT. </b><br><br> Connection is closed (it was a passive reset while performing
//an active close). <br><br>Applies only to TCP.
//<b>PLATFORM CONSTANT. </b><br><br> Connection is closed (it was a passive reset, no further
//details available). <br><br>Applies only to TCP.
//<b>PLATFORM CONSTANT. </b><br><br> Connection is closed (it was an active reset issued by the
//application). <br><br>Applies only to TCP.
//<b>PLATFORM CONSTANT. </b><br><br> Connection is closed (it was an active reset issued because
//of excessive retransmission attempts during a passive open). <br><br>Applies only to TCP.
//<b>PLATFORM CONSTANT. </b><br><br> Connection is closed (it was an active reset issued because
//of excessive retransmission attempts during an active open). <br><br>Applies only to TCP.
//<b>PLATFORM CONSTANT. </b><br><br> Connection is closed (it was an active reset issued because
//of excessive retransmission attempts while in "connection established" state).
//<br><br>Applies only to TCP.
//<b>PLATFORM CONSTANT. </b><br><br> Connection is closed (it was an active reset issued because
//of excessive retransmission attempts during a passive close). <br><br>Applies only to TCP.
//<b>PLATFORM CONSTANT. </b><br><br> Connection is closed (it was an active reset issued because
//of excessive retransmission attempts during a passive open). <br><br>Applies only to TCP.
//<b>PLATFORM CONSTANT. </b><br><br> Connection is closed (it was an active reset caused by
//connection timeout, i.e. no data was exchanged for sock.connectiontout number of
//seconds). <br><br>Applies only to TCP.
//<b>PLATFORM CONSTANT. </b><br><br> Connection is closed (it was an active reset caused by
//a data exchange error). <br><br>Applies only to TCP.
//<b>PLATFORM CONSTANT. </b><br><br> Connection is closed (it was discarded by the application).
//<br><br>Applies both to UDP and TCP.
//<b>PLATFORM CONSTANT. </b><br><br> Connection is closed (it was discarded because an error
//in connection sequence was detected during a passive open). <br><br>Applies only to TCP.
//<b>PLATFORM CONSTANT. </b><br><br> Connection is closed (it was discarded because an error
//in connection sequence was detected during an active open). <br><br>Applies only to TCP.
//<b>PLATFORM CONSTANT. </b><br><br> Connection is closed (it was discarded because the device has
//failed to resolve the IP address of the destination during an active open, i.e.
//there was no reply to ARP requests). <br><br>Applies both to UDP and TCP.
//<b>PLATFORM CONSTANT. </b><br><br> Connection is closed (it was discarded because connection has 
//timed out, i.e. no data was exchanged for sock.connectiontout number of seconds). <br><br>
//Applies only to UDP.
//<b>PLATFORM CONSTANT. </b><br><br> ARP resolution is an progress (it is an active open).
//<br><br>Applies both to UDP and TCP.
//<b>PLATFORM CONSTANT. </b><br><br> Connection is being established (it is a passive open).
//<br><br>Applies only to TCP.
//<b>PLATFORM CONSTANT. </b><br><br> Connection is being established (it is an active open).
//<br><br>Applies only to TCP.
//<b>PLATFORM CONSTANT. </b><br><br> Connection is established (generic, includes both passive
//and active open). <br><br>Applies both to UDP and TCP.  
//<b>PLATFORM CONSTANT. </b><br><br> Connection is established (it was a passive open).
//<br><br>Applies both to UDP and TCP. 
//<b>PLATFORM CONSTANT. </b><br><br> Connection is established (it was an active open).
//<br><br>Applies both to UDP and TCP.
//<b>PLATFORM CONSTANT. </b><br><br> Connection is being closed (it is a passive close).
//<br><br>Applies only to TCP. 
//<b>PLATFORM CONSTANT. </b><br><br> Connection is being closed (it is an active close).
//<br><br>Applies only to TCP.
//--------------------------------------------------------------------
//<b>ENUM. </b><br><br> Contains a simplified list of constants related to possible socket states. See also enum <font color="olive"><b>pl_sock_state</b></font>.
//<b>PLATFORM CONSTANT. </b><br><br> Connection is closed. <br><br>Applies both to UDP and TCP.
//<b>PLATFORM CONSTANT. </b><br><br> ARP resolution is an progress (it is an active open).
//<br><br>Applies both to UDP and TCP.
//<b>PLATFORM CONSTANT. </b><br><br> Connection is being established (it is a passive open).
//<br><br>Applies only to TCP.
//<b>PLATFORM CONSTANT. </b><br><br> Connection is being established (it is an active open).
//<br><br>Applies only to TCP.
//<b>PLATFORM CONSTANT. </b><br><br> Connection is established. <br><br>Applies both to UDP and TCP.  
//<b>PLATFORM CONSTANT. </b><br><br> Connection is being closed (it is a passive close).
//<br><br>Applies only to TCP. 
//<b>PLATFORM CONSTANT. </b><br><br> Connection is being closed (it is an active close).
//<br><br>Applies only to TCP.
//--------------------------------------------------------------------
//<b>ENUM. </b><br><br> 
//Contains the list of constants related to whether the socket accepts any incoming connections and, if yes, from which sources.
//<b>PLATFORM CONSTANT. </b><br><br> The socket does not accept any incoming connections.
//<b>PLATFORM CONSTANT. </b><br><br> 
//The socket will only accept an incoming connection from specific IP (matching <font color="maroon">
//<b>sock.targetip</b></font>) and specific port (matching <font color="maroon"><b>
//sock.targetport</b></font>)
//<b>PLATFORM CONSTANT. </b><br><br> 
//The socket will only accept an incoming connection from specific IP (matching <font color="maroon">
//<b>sock.targetip</b></font>), but any port.
//<b>PLATFORM CONSTANT. </b><br><br> 
//The socket will accept an incoming connection from any IP and any port.
//--------------------------------------------------------------------
//<b>ENUM. </b><br><br> 
//Contains the list of constants that specify whether the socket accepts reconnects, and, if yes, from which sources. Reconnect situation is 
//when a passive open and resulting connection replace, for the same socket, the connection that was already in progress. <br><br>
//For UDP, these constants additionally define whether a "port switchover" will occur as a result of an incoming connection (passive open)
//or a reconnect.<br><br>
//Port switchover is when the socket starts sending its outgoing UDP datagrams to the port from which the most recent UDP datagram was received,
//rather than the port specified by the <font color="maroon"><b>sock.targetport </b></font> property.
//<b>PLATFORM CONSTANT. </b><br><br> 
//For UDP: Reconnects accepted only from the same IP as the one already engaged in the current connection 
//with this socket, but any port; port switchover will not happen. <br><br>
//TCP: reconnects are not accepted at all.
//<b>PLATFORM CONSTANT. </b><br><br> 
//For UDP: Reconnects accepted from any IP, any port; port switchover will not happen. <br><br>
//TCP: reconnects accepted only from the same IP and port as the ones already engaged in the current connection 
//with this socket.
//<b>PLATFORM CONSTANT. </b><br><br> 
//For UDP: Reconnects accepted only from the same IP as the one already engaged in the current connection with 
//this socket, but any port; port switchover will happen. <br><br>
//TCP: reconnects accepted only from the same IP as the one already engaged in the current connection with this
//socket, but any port.
//<b>PLATFORM CONSTANT. </b><br><br> 
//For UDP: Reconnects accepted from any IP, any port; port switchover will happen. ,<br><br>
//TCP: reconnects accepted from any IP, any port.
//--------------------------------------------------------------------
//<b>ENUM. </b><br><br> 
//Contains the list of constants that specify the transport protocol for the socket. HTTP is not listed here because it is not a transport
//protocol (transport protocol used for HTTP is TCP).
//<b>PLATFORM CONSTANT. </b><br><br> Specifies UDP transport protocol for the socket.
//<b>PLATFORM CONSTANT. </b><br><br> Specifies TCP transport protocol for the socket.
//<b>PLATFORM CONSTANT. </b><br><br> Specifies RAW packet mode for the socket.
//--------------------------------------------------------------------
//<b>ENUM. </b><br><br> 
//Contains the list of HTTP request types supported by the internal web server.
//<b>PLATFORM CONSTANT. </b><br><br> HTTP GET request.
//<b>PLATFORM CONSTANT. </b><br><br> HTTP POST request.
//--------------------------------------------------------------------
Object.defineProperty(sock, 'numofsock', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (BYTE). </b><br><br> Returns total number of sockets available on the current platform. See also <font color="maroon"><b>
//sock.num </b></font>property.
//--------------------------------------------------------------------
Object.defineProperty(sock, 'num', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (BYTE), DEFAULT VALUE= 0 (socket #0 selected). </b><br><br>
//Sets/returns the number of the currently selected socket (sockets are enumerated from 0).<br><br>
//Most other properties and methods of this object relate to the socket selected through this property. Note that socket-related events such 
//as <font color="teal"><b>on_sock_data_arrival </b></font> change currently selected socket!<br><br>
//The value of this property won't exceed <font color="maroon"><b>sock.numofsock</b></font>-1 (even if you attempt to set higher value).
//--------------------------------------------------------------------
Object.defineProperty(sock, 'state', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0-PL_SST_CLOSED (connection is closed). </b><br><br>
//For the currently selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) returns "detailed" current socket state
//(as opposed to <font color="teal"><b>on_sock_event </b></font>that retuns detailed state at the moment of a particular <font color="teal">
//<b>on_sock_event </b></font>event generation).See <font color="olive"><b>pl_sock_state </b></font>constants for state descriptions.<br><br>
//Another read-only property- <font color="maroon"><b>sock.statesimple</b></font>- returns "simplified" socket state.
//--------------------------------------------------------------------
Object.defineProperty(sock, 'statesimple', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0-PL_SST_SIMPLE_CLOSED (connection is closed). </b><br><br>
//For the currently selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) returns "simplified" current socket state
//(as opposed to <font color="teal"><b>on_sock_event </b></font> that retuns simplified state at the moment of a particular <font color="teal">
//<b>on_sock_event </b></font> event generation). See <font color="olive"><b>pl_sock_state_simple </b></font>constants for state
//descriptions.<br><br>
//Another read-only property- <font color="maroon"><b>sock.state</b></font>- returns "detailed" socket state.
//--------------------------------------------------------------------
Object.defineProperty(sock, 'inconmode', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0- PL_SOCK_INCONMODE_NONE (does not accept any incoming connections). </b><br><br>
//For the currently selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) specifies whether incoming connections
//(passive opens) will be accepted and, if yes, from which sources: <br><br>
//<font color="olive"><b>0- PL_SOCK_INCONMODE_NONE </b></font>(incoming connections are not accepted at all),<br><br>
//<font color="olive"><b>1- PL_SOCK_INCONMODE_SPECIFIC_IPPORT </b></font>(incoming connections accepted only from specific IP (matching 
//<font color="maroon"><b>sock.targetip</b></font>) and specific port (matching <font color="maroon"><b>sock.targetport</b></font>)), <br><br>
//<font color="olive"><b>2- PL_SOCK_INCONMODE_SPECIFIC_IP_ANY_PORT </b></font>(incoming connections accepted only from specific IP (matching 
//<font color="maroon"><b>sock.targetip</b></font>), but any port),<br><br>
//<font color="olive"><b>3- PL_SOCK_INCONMODE_ANY_IP_ANY_PORT </b></font>(incoming connections accepted from any IP and any port). 
//--------------------------------------------------------------------
Object.defineProperty(sock, 'reconmode', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0- PL_SOCK_RECONMODE_0. </b><br><br>
//For the currently selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) whether the socket accepts reconnects, 
//and, if yes, from which sources. Reconnect situation is when a passive open and resulting connection replace, for the same socket, the 
//connection that was already in progress. <br><br>
//For UDP, this property additionally defines whether a "port switchover" will occur as a result of an incoming connection (passive open) or a
//reconnect. Port switchover is when the socket starts sending its outgoing UDP datagrams to the port from which the most recent UDP datagram
//was received, rather than the port specified by the <font color="maroon"><b>sock.targetport</b></font> property. <br><br>
//See <font color="olive"><b>PL_SOCK_RECONMODE_ </b></font>constants for available choices.
//--------------------------------------------------------------------
Object.defineProperty(sock, 'localportlist', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (STRING), DEFAULT VALUE= "" (empty string). </b><br><br>
//For the currently selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) sets/returns the list of listening ports
//on any of which this socket will accept an incoming UDP or TCP connection (as defined by the <font color="maroon"><b>sock.protocol </b></font>
//property and provided that incoming connections are allowed by the <font color="maroon"><b>sock.inconmode </b></font> property).
//Additionally, the
//<font color="maroon"><b>sock.allowedinterfaces </b></font>
//property defines network interfaces on which the socket will accept an incoming connection.
//<br><br>
//This property is of string type and the list of ports is a comma-separated string, i.e. "1001,3000". Max string length for this property is 
//32 bytes. <br><br>
//Notice, that there is also a <font color="maroon"><b>sock.httpportlist </b></font> property that defines a list of listening ports for HTTP 
//TCP connections.
//--------------------------------------------------------------------
Object.defineProperty(sock, 'httpportlist', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (STRING), DEFAULT VALUE= "" (empty string). </b><br><br>
//For the currently selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) sets/returns the list of listening ports
//on any of which this socket will accept an incoming HTTP connection. (provided that the <font color="maroon"><b>sock.protocol</b></font>= 
//<font color="olive"><b>1- PL_SOCK_PROTOCOL_TCP</b></font> and that incoming connections are allowed by <font color="maroon"><b>
//sock.inconmode</b></font> property). <br><br>
//This property is of string type and the list of ports is a comma-separated string, i.e. "80, 81". Max string length for this property is 32 
//bytes. Notice, that there is also a <font color="maroon"><b>sock.localportlist</b></font> property that defines a list of listening ports for
//UDP and non-HTTP TCP connections. <br><br>
//When a particular port is listed both under the <font color="maroon"><b>sock.localportlist</b></font> and the <font color="maroon"><b>
//sock.httpportlist</b></font>, the protocol for this socket is TCP then <font color="maroon"><b>sock.httpportlist</b></font> has precedence
//(incoming TCP connection on the port in question will be interpreted as HTTP). <br><br>
//See also <font color="maroon"><b>sock.localport </b></font> and <font color="maroon"><b>sock.httpmode </b></font> properties. 
//--------------------------------------------------------------------
Object.defineProperty(sock, 'localport', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD), DEFAULT VALUE= 0. </b><br><br>
//For the currently selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) returns current local port of the socket.
//<br><br>Your application cannot set the local port directly. Instead, a list of ports on which the socket is allowed to accept an incoming 
//connection (passive open) is supplied via the <font color="maroon"><b>sock.localportlist </b></font> and <font color="maroon"><b>
//sock.httpportlist </b></font> properties.<br><br>
//An incoming connection is accepted on any port from those two lists. The <font color="maroon"><b>sock.localport </b></font> property reflects 
//current or the most recent local port on which connection was accepted.
//--------------------------------------------------------------------
Object.defineProperty(sock, 'outport', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (WORD), DEFAULT VALUE= 0 (automatic). </b><br><br>
//For the currently selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) sets/returns the number of the port that
//will be used by the socket to establish outgoing connections. <br><br>
//If this property is set to 0 then the socket will use "automatic" port numbers: for the first connection since the powerup the port number will
//be selected randomly, for all subsequent outgoing connections the port number will increase by one. <br><br>
//Actual local port of a connection can be queried through the <font color="maroon"><b>sock.localport </b></font> read-only property. If this 
//property is not at zero then the port it specifies will be used for all outgoing connections from this socket.
//--------------------------------------------------------------------
Object.defineProperty(sock, 'acceptbcast', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0-NO. </b><br><br>
//For the currently selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) specifies whether the socket will accept
//incoming broadcast UDP datagrams: <br><br>
//<font color="olive"><b>0- NO </b></font>(won't accept broadcast UDP datagrams),<br><br> <font color="olive"><b>1- YES </b></font> (will accept
//broadcast UDP datagrams).<br><br>
//This property is irrelevant for TCP communications (<font color="maroon"><b>sock.protocol</b></font>=<font color="olive"><b>
//PL_SOCK_PROTOCOL_TCP</b></font>).
//--------------------------------------------------------------------
Object.defineProperty(sock, 'targetip', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (STRING), DEFAULT VALUE= "0.0.0.0". </b><br><br>
//For active opens on the currently selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) specifies the target IP
//to which the socket will attempt to connect to. <br><br>
//For passive opens, whether this property will matter or not is defined by the <font color="maroon"><b>sock.inconmode</b></font> property. 
//When the <font color="maroon"><b>sock.inconmode</b></font>= <font color="olive"><b>1- PL_SOCK_INCONMODE_SPECIFIC_IPPORT </b></font> or
//<font color="olive"><b>2- PL_SOCK_INCONMODE_SPECIFIC_IP_ANY_PORT </b></font> only the host with IP matching the one set in the 
//<font color="maroon"><b>sock.targetip</b></font> property will be able to connect to the socket.<br><br>
//current IP on the "other side" of the connection can always be checked through the <font color="maroon"><b>sock.remoteip </b></font> read-only
//property.<br><br> 
//See also <font color="maroon"><b>sock.targetport</b></font> and <font color="maroon"><b>sock.remoteport</b></font>.
//--------------------------------------------------------------------
Object.defineProperty(sock, 'targetmac', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (STRING), DEFAULT VALUE= "0.0.0.0.0.0". </b><br><br>
//--------------------------------------------------------------------
Object.defineProperty(sock, 'targetport', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (WORD), DEFAULT VALUE= 0. </b><br><br>
//For active opens on the currently selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) specifies the target port
//to which the socket will attempt to connect to. <br><br>
//For passive opens, whether this property will matter or not is defined by the <font color="maroon"><b>sock.inconmode</b></font> property. 
//When the <font color="maroon"><b>sock.inconmode</b></font>= <font color="olive"><b>1- PL_SOCK_INCONMODE_SPECIFIC_IPPORT </b></font> an incoming
//connection will only be accepted from the port matching the one set in the <font color="maroon"><b>sock.targetport</b></font> property.<br><br>
//Current port on the "other side" of the connection can always be checked through the <font color="maroon"><b>sock.remoteport</b></font>
//read-only property.<br><br>
//See also <font color="maroon"><b>sock.targetip</b></font> and <font color="maroon"><b>sock.remoteip</b></font>.
//--------------------------------------------------------------------
Object.defineProperty(sock, 'targetbcast', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0- NO. </b><br><br>
//For the currently selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) specifies whether this port will be
//sending its outgoing UDP datagrams as link-level broadcasts: <br><br>
//<font color="olive"><b>0- NO </b></font> (will send as "normal" packets),<br><br> <font color="olive"><b>1- YES </b></font>(will send as 
//broadcast packets).<br><br>
//This property is only relevant for UDP communications (<font color="maroon"><b>sock.protocol</b></font>=<font color="olive"><b>
//PL_SOCK_PROTOCOL_UDP</b></font>). When this property is set to <font color="olive"><b>1- YES </b></font>the socket will be sending out all UDP 
//datagrams as broadcasts and incoming datagrams won't cause port switchover, even if the latter is enabled through the 
//<font color="maroon"><b>sock.reconmode </b></font> property.
//--------------------------------------------------------------------
Object.defineProperty(sock, 'remotemac', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (STRING), DEFAULT VALUE= "0.0.0.0.0.0". </b><br><br>
//For the currently selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) returns the MAC address of the host with
//which this socket had the most recent or currently has a connection. <br><br>
//For UDP connections, when the <font color="teal"><b>on_sock_data_arrival </b></font>event handler is entered, the <font color="maroon"><b>
//sock.remotemac </b></font>will contain the MAC address of the sender of the current UDP datagram being processed.<br><br>
//Outside of the <font color="teal"><b>on_sock_data_arrival </b></font>event handler, the property will return the source MAC address of the most
//recent datagram received by the socket. <br><br>
//Also see <font color="maroon"><b>sock.remoteip</b></font>, <font color="maroon"><b>sock.remoteport</b></font>, and <font color="maroon"><b>
//sock.bcast </b></font> properties.
//--------------------------------------------------------------------
Object.defineProperty(sock, 'remoteip', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (STRING), DEFAULT VALUE= "0.0.0.0". </b><br><br>
//For the currently selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) returns the IP address of the host with 
//which this socket had the most recent or currently has a connection. The application cannot directly change this property, it can only specify
//the target IP address for active opens through the <font color="maroon"><b>sock.targetip </b></font> property.<br><br>
//For UDP connections, when the <font color="teal"><b>on_sock_data_arrival </b></font>event handler is entered, the <font color="maroon"><b>
//sock.remoteip </b></font> will contain the IP address of the sender of the current datagram being processed. <br><br>
//Outside of the <font color="teal"><b>on_sock_data_arrival </b></font>event handler, the property will return the source IP address of the most
//recent datagram received by the socket.<br><br>
//Also see <font color="maroon"><b>sock.remotemac</b></font>, <font color="maroon"><b>sock.remoteport</b></font>, and <font color="maroon"><b>
//sock.bcast </b></font> properties. 
//--------------------------------------------------------------------
Object.defineProperty(sock, 'remoteport', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD), DEFAULT VALUE= 0. </b><br><br>
//For the currently selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) returns the port number of the host with
//which this socket had the most recent or currently has a connection. The application cannot directly change this property, it can only specify
//the target port for active opens through the <font color="maroon"><b>sock.targetport </b></font> property. <br><br>
//For UDP connections, when the <font color="teal"><b>on_sock_data_arrival </b></font>event handler is entered, the <font color="maroon"><b>
//sock.remoteport</b></font> will contain the port number of the sender of the current datagram being processed. <br><br>
//Outside of the <font color="teal"><b>on_sock_data_arrival </b></font>event handler, the property will return the source port of the most recent
//datagram received by the socket.<br><br>
//Also see <font color="maroon"><b>sock.remotemac</b></font>, <font color="maroon"><b>sock.remoteip</b></font>, and <font color="maroon"><b>
//sock.bcast </b></font> properties.
//--------------------------------------------------------------------
Object.defineProperty(sock, 'bcast', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (ENUM BYTE), DEFAULT VALUE= 0- NO. </b><br><br>
//For the currently selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) reports whether the current or most
//recently received UDP datagram was a broadcast one. <br><br>
//When the <font color="teal"><b>on_sock_data_arrival </b></font>event handler is entered, the <font color="maroon"><b>sock.bcast </b></font> 
//will contain the broadcast status for the current datagram being processed.  <br><br>
//Outside of the <font color="teal"><b>on_sock_data_arrival </b></font>event handler, the property will return the broadcast status of the most
//recent datagram received by the socket.
//--------------------------------------------------------------------
Object.defineProperty(sock, 'protocol', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0- PL_SOCK_PROTOCOL_UDP (UDP transport protocol for the socket). </b><br><br>
//For the currently selected socket (selection is made through <font color="maroon"><b>sock.num </b></font>) selects the transport protocol:<br><br>
//<font color="olive"><b>0- PL_SOCK_PROTOCOL_UDP </b></font> (UDP transport protocol), <br><br>
//<font color="olive"><b>1- PL_SOCK_PROTOCOL_TCP</b></font> (TCP transport protocol).<br><br>
//Notice, that there is no "HTTP" selection, as HTTP is not a transport protocol (TCP is the transport protocol required by the HTTP). 
//You make the socket accept HTTP connections by specifying the list of HTTP listening ports using the <font color="maroon"><b>sock.httpportlist
//</b></font> property or using the <font color="maroon"><b>sock.httpmode </b></font> property. <br><br>
//The program won't be able to change the value of this property when the socket is not idle (<font color="maroon"><b>sock.statesimple
//</b></font><> <font color="olive"><b>0- PL_SSTS_CLOSED</b></font>).
//--------------------------------------------------------------------
Object.defineProperty(sock, 'splittcppackets', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0- NO. </b><br><br>
//For the currently selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) selects how TCP data should be processed:
// <font color="olive"><b>0- NO </b></font>(normal processing), <font color="olive"><b>1- YES </b></font>(additional degree of control over
//individual TCP packets). When this property is set to <font color="olive"><b>1- YES </b></font>your program gets an additional degree of 
//control over TCP. <br><br>
//For incoming  TCP data, the program can know the size of individual incoming packets (this will be reported by the <font color="teal"><b>
//on_sock_tcp_packet_arrival </b></font>event).<br><br>
//For outgoing TCP data, no packet will be sent out at all unless entire contents of the TX buffer can be sent. Therefore, by executing 
//<font color="maroon"><b>sock.send </b></font> and waiting for <font color="maroon"><b>sock.txlen</b></font>=0 your program can make sure that 
//the packet sent will have exactly the size you needed. <br><br>
//The property is only relevant when <font color="maroon"><b>sock.inbandcommands</b></font>= <font color="olive"><b>0- NO</b></font>. With 
//inband commands enabled, the socket will always behave as if the <font color="maroon"><b>sock.splittcppackets</b></font>= <font color="olive">
//<b>0- NO</b></font>. <br><br>
//The program won't be able to change the value of this property when the socket is not idle (<font color="maroon"><b>sock.statesimple</b></font>
//<> <font color="olive"><b>0- PL_SSTS_CLOSED</b></font>). <br>
//--------------------------------------------------------------------
Object.defineProperty(sock, 'httpmode', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM BYTE), DEFAULT VALUE= 0- NO (not in HTTP mode). </b><br><br>
//For the currently selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) specifies whether this socket is in the
//HTTP mode: <font color="olive"><b>0- NO</b></font> ("regular" TCP connection), <font color="olive"><b>1- YES </b></font>(TCP HTTP connection). 
//<br><br>This property is irrelavant when the <font color="maroon"><b>sock.protocol</b></font>= <font color="olive"><b>PL_SOCK_PROTOCOL_UDP
//</b></font>(UDP). If you do not set this property directly, it's value will be: <font color="olive"><b>0- NO</b></font> for all outgoing
//connections (active opens) of the socket, <font color="olive"><b>0- NO </b></font>for incoming connections received on one of the ports from 
//the <font color="maroon"><b>sock.localportlist</b></font> list, <font color="olive"><b>1- YES </b></font>for incoming connections received 
//on one of the ports from the <font color="maroon"><b>sock.httpportlist</b></font>.<br><br>
//You can manually switch any TCP connection at any time after it has been established from "regular" to HTTP by setting <font color="maroon"><b>
//sock.httpmode</b></font>=1. However, this operation is "sticky"- once you have converted the TCP connection into the HTTP mode you cannot 
//convert it back into the regular mode- trying to set <font color="maroon"><b>sock.httpmode</b></font>=0 won't have any effect- the TCP 
//connection will remain in the HTTP mode until this connection is closed. 
//--------------------------------------------------------------------
Object.defineProperty(sock, 'httpnoclose', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0- NO (will be closed). </b><br><br>
//For the currently selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) sets/returns whether TCP HTTP connection
//will be kept opened after the HTTP request has been processed and the HTML page has been sent out: <font color="olive"><b>0- NO</b></font> 
//(will be closed, standard behavior), <font color="olive"><b>1- YES </b></font>(will be kept open). <br><br>
//In the second case the end of HTML page output is marked by CR/LF/CR/LF sequence.
//--------------------------------------------------------------------
Object.defineProperty(sock, 'connectiontout', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (WORD), DEFAULT VALUE= 0 (no timeout). </b><br><br>
//For the currently selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) sets/returns connection timeout threshold
//for the socket in half-second increments. <br><br>
//When no data is exchanged across the connection for sock.connectiontout/2 number of seconds this connection is aborted (reset for TCP and 
//discarded for UDP). Connection timeout of 0 means "no timeout".
//<br><br>
//Actual time elapsed since the last data exchange across the socket can be obtained through the
//<font color="maroon"><b>sock.toutcounter </b></font>R/O property.
//--------------------------------------------------------------------
Object.defineProperty(sock, 'toutcounter', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD), DEFAULT VALUE= 0 </b><br><br>
//For the currently selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) returns the time, in 0.5 second intervals,
//elapsed since the data was last send or received on this socket.
//<br><br>
//This property is reset to 0 each time there is some data exchanged across the socket connection.
//The property increments at 0.5 second intervals while no data is moving through this socket.
//<br><br>
//If the <font color="maroon"><b>sock.connectiontout </b></font>
//is not at 0, this property increments until it reaches the value of the
//<font color="maroon"><b>sock.connectiontout </b></font>
//and the connection is terminated.
//The <font color="maroon"><b>sock.toutcounter </b></font>
//then stays at this value.
//<br><br>
//If the <font color="maroon"><b>sock.connectiontout </b></font>
//is at 0, the maximum value that the
//<font color="maroon"><b>sock.toutcounter </b></font>
//can reach is 1. That is, the
//<font color="maroon"><b>sock.toutcounter </b></font>
//will be at 0 after the data exchange, and at 1 if at least 0.5 seconds have passed since the last data exchange.
//--------------------------------------------------------------------
Object.defineProperty(sock, 'inbandcommands', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0- NO (inband commands disabled). </b><br><br>
//For the currently selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) specifies whether inband command passing
//is allowed: <font color="olive"><b>0- NO</b></font> (inband commands are not allowed), <font color="olive"><b>1- YES </b></font>(inband 
//commands are allowed). <br><br>
//Inband commands are messages passedwithin the TCP data stream. Each message has to be formatted in a specific way- see the <font color="maroon">
//<b>sock.escchar </b></font> and <font color="maroon"><b>sock.endchar </b></font> properties. <br><br>
//Inband commands are not possible for UDP communications so this setting is irrelevant when <font color="maroon"><b>sock.protocol</b></font>=
//<font color="olive"><b>1- PL_SOCK_PROTOCOL_UDP</b></font>. <br><br>
//Inband messaging will work even when redirection (buffer shorting) is enabled for the socket (see the <font color="maroon"><b>sock.redir 
//</b></font>method). The program won't be able to change the value of this property when the socket is not idle (<font color="maroon"><b>
//sock.statesimple</b></font><> <font color="olive"><b>0- PL_SSTS_CLOSED</b></font>).
//--------------------------------------------------------------------
Object.defineProperty(sock, 'escchar', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (BYTE), DEFAULT VALUE= 255. </b><br><br>
//For the currently selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) specifies the ASCII code of the 
//character that will be used as an escape character for inband commands (messages). Each inband message starts with "EC OC", where "EC" is the 
//escape character defined by the <font color="maroon"><b>sock.escchar </b></font> property and "OC" is any character other than "EC".<br><br>
//With inband commands enabled, data characters with code matching that of the escape character is transmitted as "EC EC". This property is
//irrelevant when inband commands are disabled (<font color="maroon"><b>sock.inbandcommands</b></font>= <font color="olive"><b>0- NO</b></font>). '<br><br>The program won't be able to change the value of this property when the socket is not idle (<font color="maroon"><b>
//sock.statesimple</b></font><> <font color="olive"><b>0- PL_SSTS_CLOSED</b></font>).<br><br>
//See also <font color="maroon"><b>sock.endchar</b></font>.
//--------------------------------------------------------------------
Object.defineProperty(sock, 'endchar', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (BYTE), DEFAULT VALUE= 13 (CR). </b><br><br>
//For the currently selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) specifies the ASCII code of the 
//character that will end inband command (message). Each inband message has to end with this character, which will mark a return to the "regular"
//data stream of the TCP connection. <br><br>
//This property is irrelevant when inband commands are disabled (<font color="maroon"><b>sock.inbandcommands</b></font>= <font color="olive"><b>
//0- NO</b></font>). The program won't be able to change the value of this property when the socket is not idle (<font color="maroon"><b>
//sock.statesimple</b></font><> <font color="olive"><b>0- PL_SSTS_CLOSED</b></font>). <br><br>
//See also <font color="maroon"><b>sock.escchar</b></font>.
//--------------------------------------------------------------------
Object.defineProperty(sock, 'gendataarrivalevent', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (BYTE), DEFAULT VALUE= 1- YES (on_sock_data_arrival event will be generated). </b><br><br>
//For the currently selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) specifies whether the <font color="teal">
//<b>on_sock_data_arrival </b></font>event will be generated once there is some data in the RX buffer: <br><br>
//<font color="olive"><b>0- NO </b></font>(<font color="teal"><b>on_sock_data_arrival </b></font>event won't be generated),<br><br>
//<font color="olive"><b>1- YES </b></font>(<font color="teal"><b>on_sock_data_arrival </b></font>event will be generated).<br><br>
//Turning <font color="teal"><b>on_sock_data_arrival </b></font>event generation off may be handy when you are processing UDP datagrams 
//(<font color="maroon"><b>sock.protocol</b></font>= <font color="olive"><b>0- PL_SOCK_PROTOCOL_UDP</b></font>) in a loop while
//using the doevents. If this is the case the <font color="teal"><b>on_sock_data_arrival </b></font>event handler executed "inside" the doevents
//would "steal" datagrams from you (the datagram is deleted from the RX buffer once the <font color="teal"><b>on_sock_data_arrival
//</b></font>event handler is exited).
//--------------------------------------------------------------------
Object.defineProperty(sock, 'rxbuffsize', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD | DWORD), DEFAULT VALUE= 0 (0 bytes). </b><br><br>
//For the currently selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) returns current RX buffer capacity in
//bytes.<br><br>
//Buffer capacity can be changed through the <font color="maroon"><b>sock.rxbuffrq</b></font>. The <font color="maroon"><b>sock.rxbuffrq
//</b></font> requests buffer size in 256-byte pages whereas this property returns buffer size in bytes.<br><br>
//Relationship between the two is as follows: <font color="maroon"><b>sock.rxbuffsize</b></font>=num_pages*256-X (or =0 when num_pages=0), 
//where "num_pages" is the number of buffer pages that was GRANTED through the <font color="maroon"><b>sock.rxbuffrq</b></font>.  "-X" is because a number of bytes is needed for internal buffer
//variables. X=17 on 16-bit platforms and 33 on 32-bit platforms.<br><br>
//The socket cannot RX data when the RX buffer has zero capacity.
//--------------------------------------------------------------------
Object.defineProperty(sock, 'txbuffsize', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD | DWORD), DEFAULT VALUE= 0 (0 bytes). </b><br><br>
//For the currently selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) returns current TX buffer capacity in
//bytes. Buffer capacity can be changed through the <font color="maroon"><b>sock.txbuffrq </b></font> method followed by the 
//<font color="maroon"><b>sys.buffalloc </b></font> method.<br><br>
//The <font color="maroon"><b>sock.txbuffrq </b></font> requests buffer size in 256-byte pages whereas this property returns buffer size in bytes.
//Relationship between the two is as follows: <font color="maroon"><b>sock.txbuffsize</b></font>=num_pages*256-X (or =0 when num_pages=0), where
//"num_pages" is the number of buffer pages that was GRANTED through the <font color="maroon"><b>sock.txbuffrq</b></font>. "-X" is because a number of bytes is needed for internal buffer
//variables. X=17 on 16-bit platforms and 33 on 32-bit platforms.<br><br>
//The socket cannot TX data when the TX buffer has zero capacity.
//--------------------------------------------------------------------
Object.defineProperty(sock, 'cmdbuffsize', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD | DWORD), DEFAULT VALUE= 0 (0 bytes). </b><br><br>
//For the currently selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) returns current CMD buffer capacity in
//bytes.<br><br>
//Buffer capacity can be changed through the <font color="maroon"><b>sock.cmdbuffrq</b></font>. The <font color="maroon"><b>sock.rxbuffrq
//</b></font> requests buffer size in 256-byte pages whereas this property returns buffer size in bytes.<br><br>
//Relationship between the two is as follows: <font color="maroon"><b>sock.cmdbuffsize</b></font>=num_pages*256-33 (or =0 when num_pages=0), 
//where "num_pages" is the number of buffer pages that was GRANTED through the <font color="maroon"><b>sock.cmdbuffrq</b></font>.  "-33" is because this number of bytes is needed for internal buffer
//variables.<br><br>
//The CMD buffer is only required when inband commands are enabled (sock.inbandcommands= 1-YES).
//--------------------------------------------------------------------
Object.defineProperty(sock, 'rplbuffsize', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD | DWORD), DEFAULT VALUE= 0 (0 bytes). </b><br><br>
//For the currently selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) returns current RPL buffer capacity in
//bytes.<br><br>
//Buffer capacity can be changed through the <font color="maroon"><b>sock.rplbuffrq</b></font>. The <font color="maroon"><b>sock.rplbuffrq
//</b></font> requests buffer size in 256-byte pages whereas this property returns buffer size in bytes.<br><br>
//Relationship between the two is as follows: <font color="maroon"><b>sock.rplbuffsize</b></font>=num_pages*256-33 (or =0 when num_pages=0), 
//where "num_pages" is the number of buffer pages that was GRANTED through the <font color="maroon"><b>sock.rplbuffrq</b></font>.  "-33" is because this number of bytes is needed for internal buffer
//variables.<br><br>
//The RPL buffer is only required when inband commands are enabled (sock.inbandcommands= 1-YES).
//--------------------------------------------------------------------
Object.defineProperty(sock, 'varbuffsize', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD | DWORD), DEFAULT VALUE= 0 (0 bytes). </b><br><br>
//For the currently selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) returns current VAR buffer capacity in
//bytes.<br><br>
//Buffer capacity can be changed through the <font color="maroon"><b>sock.varbuffrq</b></font>. The <font color="maroon"><b>sock.varbuffrq
//</b></font> requests buffer size in 256-byte pages whereas this property returns buffer size in bytes.<br><br>
//Relationship between the two is as follows: <font color="maroon"><b>sock.varbuffsize</b></font>=num_pages*256-33 (or =0 when num_pages=0), 
//where "num_pages" is the number of buffer pages that was GRANTED through the <font color="maroon"><b>sock.varbuffrq</b></font>.  "-33" is because this number of bytes is needed for internal buffer
//variables.<br><br>
//The VAR buffer is only required when you plan to use this socket in the HTTP mode- see sock.httpmode property, also sock.httpportlist.
//--------------------------------------------------------------------
Object.defineProperty(sock, 'tx2buffsize', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD | DWORD), DEFAULT VALUE= 0 (0 bytes). </b><br><br>
//For the currently selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) returns current TX2 buffer capacity in
//bytes.<br><br>
//Buffer capacity can be changed through the <font color="maroon"><b>sock.tx2buffrq</b></font>. The <font color="maroon"><b>sock.tx2buffrq
//</b></font> requests buffer size in 256-byte pages whereas this property returns buffer size in bytes.<br><br>
//Relationship between the two is as follows: <font color="maroon"><b>sock.tx2buffsize</b></font>=num_pages*256-33 (or =0 when num_pages=0), 
//where "num_pages" is the number of buffer pages that was GRANTED through the <font color="maroon"><b>sock.tx2buffrq</b></font>.  "-33" is because this number of bytes is needed for internal buffer
//variables.<br><br>
//The TX2 buffer is only required when inband commands are enabled (sock.inbandcommands= 1-YES).
//--------------------------------------------------------------------
Object.defineProperty(sock, 'httprqtype', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0 (PL_SOCK_HTTP_RQ_GET). </b><br><br>
//For the currently selected socket (selection is made through sock.num), and provided that this socket is running in the HTTP mode (sock.httpmode= 1- YES),
//returns the type of the HTTP request received from the browser.
//<br><br>
//Note that it only makes sense to query this property after the HTTP request has actually been received, i.e. in the code embedded inside or called from the HTML page.
//--------------------------------------------------------------------
Object.defineProperty(sock, 'rxlen', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD | DWORD), DEFAULT VALUE= 0 (0 bytes). </b><br><br>
//For the selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) returns total number of bytes currently waiting
//in the RX buffer to be extracted and processed by your application. <br><br>
//The <font color="teal"><b>on_sock_data_arrival </b></font>event is generated once the RX buffer is not empty, i.e. there is data to process. 
//There may be only one <font color="teal"><b>on_sock_data_arrival </b></font>event for each socket waiting to be processed in the event queue.
//<br><br>Another <font color="teal"><b>on_sock_data_arrival </b></font>event for the same socket may be generated only after the previous one 
//is handled. If, during the <font color="teal"><b>on_sock_data_arrival </b></font>event handler execution, not all data is extracted from the 
//RX buffer, another <font color="teal"><b>on_sock_data_arrival </b></font>event is generated immediately after the <font color="teal"><b>
//on_sock_data_arrival </b></font>event handler is exited.
//--------------------------------------------------------------------
Object.defineProperty(sock, 'txlen', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD | DWORD), DEFAULT VALUE=0 (0 bytes). </b><br><br>
//For the selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) returns the total number of bytes 
//currently found in the TX buffer (including the uncommitted data).<br><br>
//Your application may use the <font color="maroon"><b>sock.notifysent </b></font>method to get <font color="teal"><b>on_sock_data_sent
//</b></font>event once the total number of committed bytes in the TX buffer drops below the level defined by the <font color="maroon"><b>
//sock.notifysent</b></font> method. <br><br>
//See also <font color="maroon"><b>sock.newtxlen</b></font>.
//--------------------------------------------------------------------
Object.defineProperty(sock, 'txfree', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD | DWORD), DEFAULT VALUE=0 (0 bytes). </b><br><br>
//For the selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) returns the amount of free space in the TX 
//buffer in bytes. Sock.txfree = sock.txbufflen - sock.txlen.<br><br>
//Your application will not be able to store more data than this amount. To achieve asynchronous data processing, use the <font color="maroon">
//<b>sock.notifysent</b></font> method to get <font color="teal"><b>on_sock_data_sent</b></font> event once the TX buffer gains required 
//amount of free space.
//--------------------------------------------------------------------
Object.defineProperty(sock, 'newtxlen', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD | DWORD), DEFAULT VALUE= 0 (0 bytes). </b><br><br>
//For the selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) returns the amount of uncommitted TX data in 
//bytes. Uncommitted data is the one that was added to the TX buffer with the <font color="maroon"><b>sock.setdata </b></font> method but not 
//yet committed using the <font color="maroon"><b>sock.send </b></font>method.
//--------------------------------------------------------------------
Object.defineProperty(sock, 'httprqstring', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (STRING), DEFAULT VALUE= "". </b><br><br>
//For the selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) returns up to 255 bytes of the HTTP
//request string stored in the VAR buffer.
//<br><br>
//The <font color="maroon"><b>sock.httprqstring </b></font>
//is a property; it can be invoked several times and will return the same data (when the property is used the data is not deleted from the VAR buffer).
//<br><br>
//This property is only relevant when the socket is in the HTTP mode
//(<font color="maroon"><b>sock.httpmode</b></font>=
//<font color="olive"><b>1- YES</b></font>).
//Use it from within an HTML page or
//<font color="teal"><b>on_sock_postdata </b></font>
//event handler.
//Maximum length of data that can be obtained through this property is 255 bytes,
//since this is the maximum possible capacity of a string variable that will accept the value of this property.
//<br><br>
//Rely on the
//<font color="teal"><b>on_sock_postdata </b></font>
//event and the
//<font color="maroon"><b>sock.gethttprqstring </b></font>
//method to handle large amounts of HTTP variable data correctly.
//--------------------------------------------------------------------
sock.gethttprqstring = function (maxinplen) { };
//<b>METHOD. </b><br><br>
//For the selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) extracts up to 255 bytes of the HTTP
//request string from the VAR buffer.
//<br><br>
//Extracted data is permanently deleted from the VAR buffer.
//Length of extracted data is limited by one of the three factors (whichever is smaller):
//amount of data in the buffer itself, capacity of the "receiving" string variable, and the limit set by the maxinplen argument.
//<br><br>
//This method is only relevant when the socket is in the HTTP mode
//(<font color="maroon"><b>sock.httpmode</b></font>=
//<font color="olive"><b>1- YES</b></font>).
//Use it from within an HTML page or
//<font color="teal"><b>on_sock_postdata </b></font>
//event handler.
//<br><br>
//See also: <font color="maroon"><b>sock.httprqstring</b></font>.
//--------------------------------------------------------------------
Object.defineProperty(sock, 'rxpacketlen', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD), DEFAULT VALUE= 0 (0 bytes). </b><br><br>
//For the selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) returns the length (in bytes) of the UDP 
//datagram being extracted from the RX buffer. This property is only relevant when the <font color="maroon"><b>sock.protocol</b></font>= 
//<font color="olive"><b>1-PL_SOCK_PROTOCOL_UDP</b></font>. <br><br>
//Correct way of using this property is within the <font color="teal"><b>on_sock_data_arrival </b></font>event or in conjunction with the
//<font color="maroon"><b>sock.nextpacket</b></font> method.<br><br> 
//See also <font color="maroon"><b>sock.rxlen </b></font> property.
//--------------------------------------------------------------------
Object.defineProperty(sock, 'cmdlen', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD | DWORD), DEFAULT VALUE= 0 (0 bytes). </b><br><br>
//For the selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) returns the length of data (in bytes) waiting
//to be processed in the CMD buffer. This buffer accumulates incoming inband commands (messages) and may contain more than one such command.
//Use <font color="maroon"><b>sock.getinband </b></font> method to extract the data from the CMD buffer. <br><br>
//See also <font color="maroon"><b>sock.rpllen </b></font> and <font color="maroon"><b>sock.inbandcommands</b></font>.
//--------------------------------------------------------------------
Object.defineProperty(sock, 'varlen', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD), DEFAULT VALUE= 0 (0 bytes). </b><br><br>
//For the selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) returns the length of data (in bytes) waiting
//to be processed in the VAR buffer. This buffer accumulates incoming HTTP request string.
//Use <font color="maroon"><b>sock.gethttprqstring </b></font> method to extract the data from the CMD buffer. <br><br>
//--------------------------------------------------------------------
Object.defineProperty(sock, 'rpllen', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD | DWORD), DEFAULT VALUE= 0 (0 bytes). </b><br><br>
//For the selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) returns the length of data (in bytes) waiting
//to be send out from the RPL buffer; this is the buffer that keeps outgoing inband replies (messages). <br><br>
//Your application adds inband replies to the RPL buffer with the <font color="maroon"><b>sock.setsendinband </b></font> method. Several 
//inband replies may be waiting in the RPL buffer.<br><br>
//See also <font color="maroon"><b>sock.cmdlen</b></font>, <font color="maroon"><b>sock.rplfree </b></font> and <font color="maroon"><b>
//sock.inbandcommands</b></font>.
//--------------------------------------------------------------------
Object.defineProperty(sock, 'rplfree', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD | DWORD), DEFAULT VALUE= 0 (0 bytes). </b><br><br>
//For the selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) returns the free space (in bytes) available in
//the RPL buffer; this is the buffer that stores outgoing inband replies (messages). <br><br>
//Your application adds inband replies to the RPL buffer with the <font color="maroon"><b>sock.setsendinband </b></font> method. Several inband
//replies may be waiting in the RPL buffer.<br><br>
//See also <font color="maroon"><b>sock.cmdlen</b></font>, <font color="maroon"><b>sock.rpllen </b></font> and <font color="maroon"><b>
//sock.inbandcommands</b></font>.
//--------------------------------------------------------------------
Object.defineProperty(sock, 'tx2len', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD | DWORD), DEFAULT VALUE= 0 (0 bytes). </b><br><br>
//For the selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) returns the amount of data waiting to be sent
//out in the TX2 buffer; this is the buffer that is needed to transmit outgoing TCP data when inband commands (messages) are enabled
//(<font color="maroon"><b>sock.inbandcommands</b></font>= <font color="olive"><b>1- YES</b></font>).<br><br>
//If your application needs to make sure that all data is actually sent out then it must verify that both TX and TX2 buffers are empty.<br><br>
//See also <font color="maroon"><b>sock.txlen</b></font> and <font color="maroon"><b>sock.txfree</b></font>.
//--------------------------------------------------------------------
sock.rxclear = function () { };
//<b>METHOD. </b><br><br>
//For the selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) clears (deletes all data from) the RX buffer.
//Invoking this method will have no effect when the socket is in the HTTP mode (<font color="maroon"><b>sock.httpmode</b></font>= 
//<font color="olive"><b>1- YES</b></font>).
//--------------------------------------------------------------------
sock.txclear = function () { };
//<b>METHOD. </b><br><br>
//For the selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) clears (deletes all data from) the TX buffer.
//Invoking this method will have no effect when the socket is not idle (<font color="maroon"><b>sock.statesimple</b></font><> 
//<font color="olive"><b>0- PL_SSTS_CLOSED</b></font>).
//--------------------------------------------------------------------
sock.getdata = function (maxinplen) { };
//<b>METHOD. </b><br><br>
//For the selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) returns the string that contains the data
//extracted from the RX buffer. Extracted data is permanently deleted from the buffer. <br><br>
//Length of extracted data is limited by one of the three factors (whichever is smaller): amount of data in the RX buffer itself, capacity of 
//the "receiving" string variable, and the limit set by the maxinplen argument.<br><br>
//Additionally, if this socket uses UDP transport protocol (<font color="maroon"><b>sock.protocol</b></font>= <font color="olive"><b>
//1-PL_SOCK_PROTOCOL_TCP</b></font>) the length of data that will be extracted is limited to the UDP datagram being processed. <br><br>
//Additional conditions apply to UDP datagram processing; see <font color="teal"><b>on_sock_data_arrival </b></font>event and 
//<font color="maroon"><b>sock.nextpacket </b></font> method.
//--------------------------------------------------------------------
sock.peekdata = function (maxinplen) { };
//METHOD.
//For the selected socket (selection is made through sock.num) returns the string that contains the "preview" of the data
//from the RX buffer. The data is NOT deleted from the buffer. For TCP (sock.protocol= 1- PL_SOCK_PROTOCOL_UDP) the length of returned data is
//limited by one of the three factors (whichever is smaller): amount of data in the RX buffer itself, capacity of the
//"receiving" string variable, and the limit set by the maxinplen argument. String variables can hold up to 255 bytes of data, so this
//method will only allow you to preview up to 255 "next" bytes from the RX buffer.
//For UDP (sock.protocol= 0- PL_SOCK_PROTOCOL_UDP), additional limitations apply. The "current" UDP datagram is always deleted automatically
//when the on_sock_data_arrival event is exited. This means that you will "lose" this datagram from the buffer upon exiting the
//on_sock_data_arrival event even if your program only used sock.peekdata. Also, the amount of data returned by the sock.peekdata is
//limited to the "next" UDP datagram waiting in the RX buffer.
//See on_sock_data_arrival event and sock.nextpacket methods for additional info. See also: sock.getdata method.
//--------------------------------------------------------------------
sock.setdata = function (txdata) { };
//<b>METHOD. </b><br><br>
//For the selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) adds the data passed in the txdata argument to
//the contents of the TX buffer. If the buffer doesn't have enough space to accommodate the data being added then this data will be truncated. 
//Newly saved data is not sent out immediately. This only happens after the <font color="maroon"><b>sock.send</b></font> method
//is used to commit the data. This allows your application to prepare large amounts of data before sending it out.<br><br>
//Total amount of newly added (uncommitted) data in the buffer can be checked through the <font color="maroon"><b>sock.newtxlen </b></font> 
//setting. <br><br>
//Also see <font color="maroon"><b>sock.txlen</b></font>, <font color="maroon"><b>sock.txfree</b></font>, <font color="maroon"><b>
//sock.notifysent</b></font>, and <font color="teal"><b>on_sock_data_sent</b></font>.
//--------------------------------------------------------------------
sock.send = function () { };
//<b>METHOD. </b><br><br>
//For the selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) commits (allows sending) the data that was
//previously saved into the TX buffer using the <font color="maroon"><b>sock.setdata </b></font> method. <br><br>
//You can monitor the sending progress by checking the <font color="maroon"><b>sock.txlen</b></font> property or using the 
//<font color="maroon"><b>sock.notifysent</b></font> method and the <font color="teal"><b>on_sock_data_sent</b></font> event. 
//--------------------------------------------------------------------
sock.getinband = function () { };
//<b>METHOD. </b><br><br>
//For the selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) returns the string that contains the data
//extracted from the CMD buffer; this is the buffer that accumulates inband commands. <br><br>
//Extracted data is permanently deleted from the CMD buffer. Length of extracted data is limited by one of the two factors (whichever is 
//smaller): amount of data in the CMD buffer itself, and the capacity of the "receiving" buffer variable. <br><br>
//Several inband commands may be waiting in the CMD buffer. Each command will always be complete, i.e. there will be no situation when you
//will extract a portion of the command because the end of this command hasn't arrived yet. <br><br>
//Inband commands stored in the CMD buffer will have escape character (see <font color="maroon"><b>sock.escchar </b></font> property) and the 
//next character after the escape character already cut off, but the end character (see <font color="maroon"><b>sock.endchar </b></font> 
//property) will still be present. Therefore, your application can separate inband command from each other by finding end characters.
//--------------------------------------------------------------------
sock.peekinband = function () { };
//METHOD.
//For the selected socket (selection is made through sock.num) returns the string that contains the "preview" of the data from
//the CMD buffer; this is the buffer that accumulates inband commands. The data is NOT deleted from the
//CMD buffer. Length of extracted data is limited by one of the two factors (whichever is smaller):
//amount of data in the CMD buffer itself, and the capacity of the "receiving" buffer variable. String variables can hold up
//to 255 bytes of data, so this method will only allow you to preview up to 255 "next" bytes from the RX buffer.
//Several inband commands may be waiting in the CMD buffer. Commands stored in the CMD buffer will have escape character
//(see sock.escchar property) and the next character after the escape character already cut off, but the end character
//(see sock.endchar property) will still be present. Therefore, your application can separate inband command from each other by
//finding end characters. Internally, the CMD buffer always stores complete commands. The sock.peekinband method only allows you
//to preview "next" 255 bytes of the buffer contents, therefore, the preview of the data may contain a partial command.
//See also: sock.getinband method. 
//--------------------------------------------------------------------
sock.setsendinband = function (data) { };
//<b>METHOD. </b><br><br>
//For the selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) puts the data into the RPL buffer; this is the
//buffer that stores outgoing inband replies (messages). This method also commits the newly stored data. This is different from the
//TX buffer for which two separate methods- <font color="maroon"><b>sock.setdata </b></font> and <font color="maroon"><b>sock.send</b></font>- 
//are used to store and commit the data. <br><br>
//It is the responsibility of your application to properly encapsulate outgoing messages with escape sequence ("EC OC", see the 
//<font color="maroon"><b>sock.escchar </b></font> property) and the end character (see the <font color="maroon"><b>sock.endchar </b></font>
//property). <br><br>
//When adding the data to the RPL buffer make sure you are adding entire inband message at once- you are not allowed to do this "in portions"!
//--------------------------------------------------------------------
sock.notifysent = function (threshold) { };
//<b>METHOD. </b><br><br>
//Using this method for the selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) will cause the 
//<font color="teal"><b>on_sock_data_sent </b></font>event to be generated when the amount of committed data in the TX buffer is found to be 
//equal or below "threshold" number of bytes.<br><br>
//Only one <font color="teal"><b>on_sock_data_sent </b></font>event will be generated each time after the <font color="maroon"><b>
//sock.notifysent</b></font> is invoked. <br><br>
//This method, together with the <font color="teal"><b>on_sock_data_sent </b></font>event provides a way to handle data sending asynchronously.
//Just like with <font color="maroon"><b>sock.txfree</b></font>, the trigger you set won't take into account any uncommitted data in the TX 
//buffer.
//--------------------------------------------------------------------
sock.nextpacket = function () { };
//<b>METHOD. </b><br><br>
//For the selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) in the UDP mode (<font color="maroon"><b>
//sock.protocol</b></font>= <font color="olive"><b>0- PL_SOCK_PROTOCOL_UDP</b></font>) closes processing of current UDP datagram and moves to 
//the next datagram. <br><br>
//For UDP, the <font color="maroon"><b>sock.getdata </b></font>method only extracts the data from a single UDP datagram even if several 
//datagrams are stored in the RX buffer. When incoming UDP datagram processing is based on the <font color="teal"><b>on_sock_data_arrival
//</b></font>event the use of the <font color="maroon"><b>sock.nextpacket </b></font> is not required since each invocation of the 
//<font color="teal"><b>on_sock_data_arrival </b></font>event handler "moves" processing to the next UDP datagram.<br><br>
//The method is useful when it is necessary to move to the next datagram without re-entering <font color="teal"><b>on_sock_data_arrival
//</b></font>. Therefore, <font color="maroon"><b>sock.nextpacket </b></font> is only necessary when the application needs to process
//several incoming UDP packets at once and within a single event handler.
//--------------------------------------------------------------------
sock.connect = function () { };
//<b>METHOD. </b><br><br>
//For the selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) causes the socket to attempt to connect to 
//the target host specified by the <font color="maroon"><b>sock.targetport</b></font> and <font color="maroon"><b>sock.targetip</b></font>
//(unless, for UDP, the socket is to broadcast the data- see the <font color="maroon"><b>sock.targetbcast </b></font> property).
//<br><br>
//Outgoing connection will be attempted through the network interface defined by the
//<font color="maroon"><b>sock.targetinterface </b></font>
//property.
//<br><br>
//Method invocation will have effect only if connection was closed at the time when the method was called (<font color="maroon"><b>sock.state
//</b></font> in one of <font color="olive"><b>PL_SST_CLOSED </b></font> states). 
//--------------------------------------------------------------------
sock.close = function () { };
//<b>METHOD. </b><br><br>
//For the selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) causes the socket to close the connection 
//with the other host. <br><br>
//For established TCP connections this will be a "graceful disconnect", if the TCP connection was in the "connection opening" or "connection
//closing" state this will be a reset (just like when the <font color="maroon"><b>sock.reset </b></font> method is used).<br><br>
//If connection was in the ARP phase or the transport protocol was UDP (<font color="maroon"><b>sock.protocol</b></font>= 0- 
//<font color="olive"><b>0- PL_SOCK_PROTOCOL_UDP</b></font>) the connection will be discarded (just like when the <font color="maroon"><b>
//sock.discard </b></font> method is used). <br><br>
//Method invocation will have NO effect if connection was closed at the time when the method was called (<font color="maroon"><b>sock.state
//</b></font>in one of <font color="olive"><b>PL_SST_CLOSED </b></font> states).
//--------------------------------------------------------------------
sock.reset = function () { };
//<b>METHOD. </b><br><br>
//For the selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) causes the socket to abort the connection with
//the other host. <br><br>
//For TCP connections that were established, being opened, or being closed this will be a reset (RST will be sent to the other end of the 
//connection).<br><br>
//If connection was in the ARP phase or the transport protocol was UDP (<font color="maroon"><b>sock.protocol</b></font>= <font color="olive">
//<b>0- PL_SOCK_PROTOCOL_UDP</b></font>) the connection will be discarded (just like when the <font color="maroon"><b>sock.discard </b></font>
//method is used). <br><br>
//Method invocation will have NO effect if connection was closed at the time when the method was called (<font color="maroon"><b>
//sock.state</b></font> in one of <font color="olive"><b>PL_SST_CLOSED </b></font> states). <br><br>
//See also <font color="maroon"><b>sock.close </b></font> method.
//--------------------------------------------------------------------
sock.discard = function () { };
//<b>METHOD. </b><br><br>
//For the selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) causes the socket to discard the connection 
//with the other host. Discarding the connection means simply forgetting about it without notifying the other side of the connection
//in any way. <br><br>
//See also <font color="maroon"><b>sock.close </b></font> and <font color="maroon"><b>sock.reset </b></font> methods.
//--------------------------------------------------------------------
sock.rxbuffrq = function (numpages) { };
//<b>METHOD. </b><br><br>
//For the selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) pre-requests "numpages" number of buffer pages
//(1 page= 256 bytes) for the RX buffer of the socket. Returns actual number of pages that can be allocated.<br><br>
//Actual allocation happens when the <font color="maroon"><b>sys.buffalloc </b></font> method is used. The socket is unable to RX data if its RX
//buffer has 0 capacity. Actual current buffer capacity can be checked through the <font color="maroon"><b>sock.rxbuffsize </b></font> which
//returns buffer capacity in bytes. Relationship between the two is as follows:<br><br>
//<font color="maroon"><b>sock.rxbuffsize</b></font>=num_pages*256-X (or =0 when num_pages=0), where "num_pages" is the number of buffer pages
//that was GRANTED through the <font color="maroon"><b>sock.rxbuffrq</b></font>. "-X" is because a number of bytes is needed for internal buffer
//variables. X=17 on 16-bit platforms and 33 on 32-bit platforms.
//<br><br>
//Buffer allocation will not work if the socket to which this buffer belongs is not idle (<font color="maroon"><b>sock.statesimple</b></font><>
//<font color="olive"><b>0- PL_SSTS_CLOSED</b></font>) at the time when <font color="maroon"><b>sys.buffalloc </b></font> executes. You can only change 
//buffer sizes of sockets that are closed.
//<br><br>
//<b>On the EM2000 and other 32-bit platforms, the maximum number of pages you can request for one buffer is limited to 255.</b>
//<br><br>
//See also <font color="maroon"><b>sock.txbuffrq </b></font> method.
//--------------------------------------------------------------------
sock.txbuffrq = function (numpages) { };
//<b>METHOD. </b><br><br>
//For the selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) pre-requests "numpages" number of buffer pages
//(1 page= 256 bytes) for the TX buffer of the socket. Returns actual number of pages that can be allocated.<br><bR>
//Actual allocation happens when the <font color="maroon"><b>sys.buffalloc </b></font>method is used. The socket is unable to TX data if its TX 
//buffer has 0 capacity. Actual current buffer capacity can be checked through the <font color="maroon"><b>sock.txbuffsize </b></font> which
//returns buffer capacity in bytes. Relationship between the two is as follows: <br><br>
//<font color="maroon"><b>sock.txbuffsize</b></font>=num_pages*256-X (or =0 when num_pages=0), where "num_pages" is the number of buffer pages
//that was GRANTED through the <font color="maroon"><b>sock.txbuffrq</b></font>. "-X" is because a number of bytes is needed for internal buffer
//variables. X=17 on 16-bit platforms and 33 on 32-bit platforms.<br><br>
//Buffer allocation will not work if the socket to which this buffer belongs is not idle (<font color="maroon"><b>sock.statesimple</b></font><>
//<font color="olive"><b>0- PL_SSTS_CLOSED</b></font>) at the time when <font color="maroon"><b>sys.buffalloc </b></font> executes. You can only change 
//buffer sizes of sockets that are closed.
//<br><br>
//<b>On the EM2000 and other 32-bit platforms, the maximum number of pages you can request for one buffer is limited to 255.</b>
//<br><br>
//See also <font color="maroon"><b>sock.tx2buffrq </b></font> method.
//--------------------------------------------------------------------
sock.cmdbuffrq = function (numpages) { };
//<b>METHOD. </b><br><br>
//For the selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) pre-requests "numpages" number of buffer pages
//(1 page= 256 bytes) for the CMD buffer of the socket; this is the buffer that accumulates incoming inband commands (messages). Returns actual 
//number of pages that can be allocated. <br><br>
//Actual allocation happens when the <font color="maroon"><b>sys.buffalloc </b></font> method is used. The socket is unable to receive inband
//commands if its CMD buffer has 0 capacity.<br><br>
//Unlike for TX or RX buffers there is no property to read out actual CMD buffer capacity in bytes. This capacity can be calculated as 
//num_pages*256-X (or =0 when num_pages=0), where "num_pages" is the number of buffer pages that was GRANTED through the <font color="maroon"><b>sock.cmdbuffrq</b></font>. 
// "-X" is because a number of bytes is needed for internal buffer
//variables. X=17 on 16-bit platforms and 33 on 32-bit platforms.<br><br>
//Buffer allocation will not work if the socket to which this buffer belongs is not idle (<font color="maroon"><b>sock.statesimple</b></font><>
//<font color="olive"><b>0- PL_SSTS_CLOSED</b></font>) at the time when <font color="maroon"><b>sys.buffalloc </b></font> executes. You can only change 
//buffer sizes of sockets that are closed.
//<br><br>
//<b>On the EM2000 and other 32-bit platforms, the maximum number of pages you can request for one buffer is limited to 255.</b>
//<br><br>
//See also <font color="maroon"><b>sock.rplbuffrq </b></font> method.
//--------------------------------------------------------------------
sock.rplbuffrq = function (numpages) { };
//<b>METHOD. </b><br><br>
//For the selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) pre-requests "numpages" number of buffer pages
//(1 page= 256 bytes) for the RPL buffer of the socket; this is the buffer that stores outgoing inband replies (messages). Returns actual number
//of pages that can be allocated.<br><br>
//Actual allocation happens when the <font color="maroon"><b>sys.buffalloc </b></font>method is used. The socket is unable to send inband replies
//if its RPL buffer has 0 capacity.<br><br>
//Unlike for TX or RX buffers there is no property to read out actual RPL buffer capacity in bytes. This capacity can be calculated as 
//num_pages*256-X (or =0 when num_pages=0), where "num_pages" is the number of buffer pages that was GRANTED through the <font color="maroon">
//<b>sock.rplbuffrq</b></font>.  "-X" is because a number of bytes is needed for internal buffer
//variables. X=17 on 16-bit platforms and 33 on 32-bit platforms.<br><br>
//Buffer allocation will not work if the socket to which this buffer belongs is not idle (<font color="maroon"><b>sock.statesimple</b></font><>
//<font color="olive"><b>0- PL_SSTS_CLOSED</b></font>) at the time when <font color="maroon"><b>sys.buffalloc </b></font> executes. You can only change 
//buffer sizes of sockets that are closed.
//<br><br>
//<b>On the EM2000 and other 32-bit platforms, the maximum number of pages you can request for one buffer is limited to 255.</b>
//<br><br>
//See also <font color="maroon"><b>sock.cmdbuffrq </b></font> method.
//--------------------------------------------------------------------
sock.varbuffrq = function (numpages) { };
//<b>METHOD. </b><br><br>
//For the selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) pre-requests "numpages" number of buffer pages
//(1 page= 256 bytes) for the VAR buffer of the socket; this is the buffer that stores the HTTP request string. Returns actual number of pages 
//that can be allocated. <br><br>
//Actual allocation happens when the <font color="maroon"><b>sys.buffalloc </b></font> method is used. The socket is unable to receive HTTP 
//request string if its VAR buffer has 0 capacity. <br><br>
//Unlike for TX or RX buffers there is no property to read out actual VAR buffer capacity in bytes. This capacity can be calculated as 
//num_pages*256-X (or =0 when num_pages=0), where "num_pages" is the number of buffer pages that was GRANTED through the sock.varbuffrq. 
// "-X" is because a number of bytes is needed for internal buffer
//variables. X=17 on 16-bit platforms and 33 on 32-bit platforms.<br><br>
//Buffer allocation will not work if the socket to which this buffer belongs is not idle (<font color="maroon"><b>sock.statesimple</b></font><>
//<font color="olive"><b>0- PL_SSTS_CLOSED</b></font>) at the time when <font color="maroon"><b>sys.buffalloc </b></font> executes. You can only change 
//buffer sizes of sockets that are closed.
//<br><br>
//<b>On the EM2000 and other 32-bit platforms, the maximum number of pages you can request for one buffer is limited to 255.</b>
//<br><br>
//The VAR buffer is only required when you plan to use this socket in the HTTP mode- see <font color="maroon"><b>sock.httpmode</b></font> 'roperty, also <font color="maroon"><b>sock.httpportlist</b></font>.
//--------------------------------------------------------------------
sock.tx2buffrq = function (numpages) { };
//<b>METHOD. </b><br><br>
//For the selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) pre-requests "numpages" number of buffer pages
//(1 page= 256 bytes) for the TX2 buffer of the socket; this buffer is required when inband commands are enabled (<font color="maroon"><b>
//sock.inbandcommands</b></font>= <font color="olive"><b>1- YES</b></font>), without it the socket won't be able to TX data. <br><br>
//Returns actual number of pages that can be allocated. Actual allocation happens when the <font color="maroon"><b>sys.buffalloc </b></font>
//method is used.<br><br>
//Unlike for TX or RX buffers there is no property to read out actual TX2 buffer capacity in bytes. This capacity can be calculated as 
//num_pages*256-X (or =0 when num_pages=0), where "num_pages" is the number of buffer pages that was GRANTED through the <font color="maroon"><b>
//sock.tx2buffrq</b></font>. "-X" is because a number of bytes is needed for internal buffer
//variables. X=17 on 16-bit platforms and 33 on 32-bit platforms.<br><br>
//Buffer allocation will not work if the socket to which this buffer belongs is not idle (<font color="maroon"><b>sock.statesimple</b></font><>
//<font color="olive"><b>0- PL_SSTS_CLOSED</b></font>) at the time when <font color="maroon"><b>sys.buffalloc </b></font> executes. You can only change 
//buffer sizes of sockets that are closed.
//<br><br>
//<b>On the EM2000 and other 32-bit platforms, the maximum number of pages you can request for one buffer is limited to 255.</b>
//--------------------------------------------------------------------
sock.redir = function (redir) { };
//<b>METHOD. </b><br><br>
//For the selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) redirects the data being RXed to the TX buffer
//of the same socket, different socket, or another object that supports compatible buffers.<br><br>
//The redir argument, as well as the value returned by this method are of "<font color="olive"><b>enum pl_redir</b></font>" type. The 
//<font color="olive"><b>pl_redir </b></font>defines a set of inter-object constants that include all possible redirections for this platform.
//Specifying redir value of <font color="olive"><b>0- PL_REDIR_NONE </b></font> cancels redirection.<br><br>
//This method returns actual redirection result: <font color="olive"><b>0- PL_REDIR_NONE </b></font>if redirection failed or the
//same value as the one that was passed in the redir argument if redirection was successful.
//--------------------------------------------------------------------
Object.defineProperty(sock, 'inconenabledmaster', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE= 1- YES (incoming connections are globally enabled). </b><br><br>
//A master switch that globally defines whether incoming connections will be accepted: <font color="olive"><b>0- NO </b></font>(no socket will be
//allowed to accept an incoming connection), <font color="olive"><b>1- YES </b></font>(incoming connections are globally enabled; individual 
//socket's behavior and whether it will accept or reject a particular incoming connection depends on the setup of this socket).<br><br>
//This property can be used to temporarily disable incoming connection acceptance on all sockets without changing individual setup of each socket.
//--------------------------------------------------------------------
Object.defineProperty(sock, 'urlsubstitutes', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (STRING), DEFAULT VALUE= "" (no substitutes set). </b><br><br>
//A comma-separated list of filenames whose extensions will be automatically substituted for <i>.html </i>by the internal webserver of your device.
//Max string length for this property is 40 bytes.
//<br><br>
//The substitution will be used only if the resource file with the requested file name is not included in the project directly.
//<br><br>
//For example, setting this property to <i>pix1.bmp </i>will force the webserver to actually process <i>pix1.html</i>, but only if the file
//<i>pix1.bmp </i>is not found.
//Data output by the webserver to the browser will still look like a <i>.bmp </i>file.
//For this to work, the <i>pix1.html </i>must exist in the project.
//<br><br>
//This property allows programmatic generation of non-HTML files. In the above example it is possible to generate the BMP file through a
//BASIC code. There is no other way to do this, since only HTML files are parsed for BASIC code inclusions.
//--------------------------------------------------------------------
Object.defineProperty(sock, 'sinkdata', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0- NO (normal data processing). </b><br><br>
//For the currently selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>)
//specifies whether the incoming data should be discarded.
//<br><br>
//Setting this property to
//<font color="olive"><b>1- YES </b></font>
//causes the socket to automatically discard all incoming data without passing it to your application.
//<br><br>
//The <font color="teal"><b>on_sock_data_arrival </b></font>
//event will not be generated, reading
//<font color="maroon"><b>sock.rxlen </b></font>
//will always return zero, and so on. No data will be reaching its destination even in case of buffer redirection
//(see <font color="maroon"><b>sock.redir</b></font>).
//<br><br>
//Inband commands
//(see <font color="maroon"><b>sock.unband</b></font>)
//will still be extracted from the incoming data stream and processed.
//<font color="maroon"><b>Sock.connectiontout </b></font>and
//<font color="maroon"><b>sock.toutcounter </b></font>
//will work correctly as well. 
//--------------------------------------------------------------------
Object.defineProperty(sock, 'allowedinterfaces', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (STRING), DEFAULT VALUE is platform-dependent.</b>
//<br><br>
//For the selected socket (selection is made through <font color="maroon"><b>sock.num</b></font>) defines the list of network interfaces on which
//this socket will accept incoming connections.
//<br><br>
//Interfaces that can be on the list are: "NET" (Ethernet), "WLN" (Wi-Fi), "PPP", and "PPPoE".
//The list of allowed interfaces is comma-delimited, i.e. "WLN,NET".
//<br><br>
//Note that reading back the value of this property may not necessarily return the items in the same order as they were set.
//For example, the application may write "WLN,NET" into this property, yet read "NET,WLN" back. Unsupported interface
//names will be dropped from the list automatically.
//<br><br>
//The list of interfaces supported by your platform can be checked through
//<font color="maroon"><b>sock.availableinterfaces</b></font>.
//Only interfaces from this list can be specified as "allowed". Trying to allow an unsopported interface will not work.
//<br><br>
//See also:
//<font color="maroon"><b>sock.targetinterface</b></font>,
//<font color="maroon"><b>sock.currentinterface</b></font>.
//--------------------------------------------------------------------
Object.defineProperty(sock, 'availableinterfaces', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD). </b><br><br>
//Returns the comma-delimited list of network interfaces available on this platform.
//<br><br>
//This list may possibly include: "NET" (Ethernet), "WLN" (Wi-Fi), "PPP", and "PPPoE".
//Different platforms support a different set of interfaces.
//<br><br>
//See also:
//<font color="maroon"><b>sock.targetinterface</b></font>,
//<font color="maroon"><b>sock.currentinterface</b></font>,
//<font color="maroon"><b>sock.allowedinterfaces</b></font>.
//--------------------------------------------------------------------
Object.defineProperty(sock, 'targetinterface', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE= 1- PL_SOCK_INTERFACE_NET</b>.
//<br><br>
//For the selected socket (selection is made through
//<font color="maroon"><b>sock.num</b></font>)
//selects the network interface through which an outgoing connection will be established.
//<br><br>
//The list of possible values reflects the set of interfaces available on the selected platform.
//There is always one extra item on the list -- NULL interface. As the name implies, this is not an empty interface.
//Connection cannot be made on it.
//<br><br>
//See also:
//<font color="maroon"><b>sock.availableinterfaces</b></font>,
//<font color="maroon"><b>sock.currentinterface</b></font>,
//<font color="maroon"><b>sock.allowedinterfaces</b></font>.
//--------------------------------------------------------------------
Object.defineProperty(sock, 'currentinterface', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0- PL_SOCK_INTERFACE_NULL</b>.
//<br><br>
//For the selected socket (selection is made through
//<font color="maroon"><b>sock.num</b></font>)
//returns the network interface this socket is currently communicating through.
//<br><br>
//The list of possible values reflects the set of interfaces available on the selected platform.
//There is always one extra item on the list -- NULL interface. It means that the socket hasn't been engaged in any connection yet.
//<br><br>
//The value of this property is only valid when the socket is not idle, i.e.
//<font color="maroon"><b>sock.statesimple </b></font>
//is not equal to
//<font color="olive"><b>0- PL_SSTS_CLOSED</b></font>.
//<br><br>
//See also:
//<font color="maroon"><b>sock.availableinterfaces</b></font>,
//<font color="maroon"><b>sock.targetinterface</b></font>,
//<font color="maroon"><b>sock.allowedinterfaces</b></font>.
//--------------------------------------------------------------------
//<b>EVENT of the sock object. </b><br><br>
//At least one data byte is present in the CMD buffer (<font color="maroon"><b>sock.cmdlen</b></font>>0). Use the <font color="maroon"><b>
//sock.getinband </b></font> method to extract the data from the CMD buffer. <br><br>
//Another <font color="teal"><b>on_inband_command </b></font>event on a particular socket is never generated until the previous 
//one is processed. When the event handler is entered the <font color="maroon"><b>sock.num </b></font>is automatically switched to the 
//socket on which this event was generated. 
//--------------------------------------------------------------------
//<b>EVENT of the sock object. </b><br><br>
//Generated when at least one data byte is present in the VAR buffer of the socket,
//but only after the VAR buffer has become full at least once in the cause of the current HTTP request processing.
//<br><br>
//Two same-socket <font color="teal"><b>on_sock_postdata </b></font>events never wait in the queue -- the next event can only be generated after the previous one is processed.
//<br><br>
//Use the
//<font color="maroon"><b>sock.gethttprqstring </b></font>
//method or
//<font color="maroon"><b>sock.httprqstring </b></font>
//property to work with the VAR buffer's data.
//--------------------------------------------------------------------
//<b>EVENT of the sock object. </b><br><br> 
//Generated when at least one data byte is present in the RX buffer of the socket (i.e. for this socket the <font color="maroon"><b>
//sock.rxlen</b></font>>0). When the event handler for this event is entered the <font color="maroon"><b>sock.num </b></font>property is
//automatically switched to the socket for which this event was generated.<br><br>
//Another <font color="teal"><b>on_sock_data_arrival </b></font>event on a particular socket is never generated until the previous 
//one is processed. Use <font color="maroon"><b>sock.getdata </b></font>method to extract the data from the RX buffer.<br><br>
//For TCP protocol (<font color="maroon"><b>sock.protocol</b></font>= <font color="olive"><b>1- PL_SOCK_PROTOCOL_TCP</b></font>), there is 
//no separation into individual packets and you get all arriving data as a "stream". You don't have to process all data in the RX buffer at 
//once. If you exit the <font color="teal"><b>on_sock_data_arrival </b></font>event handler while there is still some unprocessed 
//data in the RX buffer another <font color="teal"><b>on_sock_data_arrival </b></font>event will be generated immediately.<br><br>
//For UDP protocol (<font color="maroon"><b>sock.protocol</b></font>= <font color="olive"><b>0- PL_SOCK_PROTOCOL_UDP</b></font>), the RX 
//buffer preserves datagram boundaries. Each time you enter the <font color="teal"><b>on_sock_data_arrival </b></font>event handler
//you get to process next UDP datagram. If you do not process entire datagram contents the unread portion of the datagram is discarded once 
//you exit the event handler.<br><br>
//This event is not generated for a particular socket when buffer redirection is set for this socket through the <font color="maroon"><b>
//sock.redir </b></font>method.
//--------------------------------------------------------------------
//<b>EVENT of the sock object. </b><br><br> 
//Notifies your program that the socket state has changed.
//<br><br>
//The newstate and newstatesimple arguments carry the state as it was at the moment of event generation.
//This is different from
//<font color="maroon"><b>sock.state </b></font>and
//<font color="maroon"><b> sock.statesimple</b></font>
//R/O properties that return current socket state.
//<br><br>
//See <font color="olive"><b>pl_sock_state </b></font>and
//<font color="olive"><b>pl_sock_state_simple </b></font>
//constants for description of reported socket states.
//<br><br>
//Multiple
//<font color="olive"><b>on_sock_event </b></font>
//events may be waiting in the event queue. For this reason the doevents statement will be skipped (not executed) if encountered within the event handler
//for this event or the body of any procedure in the related call chain.
//--------------------------------------------------------------------
//<b>EVENT of the sock object. </b><br><br> Data overrun has occurred in the RX buffer of the socket. Normally, this can only happen
//for UDP communications as UDP has no "data flow control" and, hence, data overruns are normal.
//<br><br>
//Another <font color="teal"><b>
//on_sock_overrun </b></font>event on a particular socket is never generated until the previous one is processed.
//<br><br>
//When event handler for this event is entered the <font color="maroon"><b>sock.num  </b></font>is automatically switched to the socket on 
//which this event was generated.
//--------------------------------------------------------------------
//<b>EVENT of the sock object. </b><br><br> 
//Generated after the total amount of committed data in the TX buffer of the socket (<font color="maroon"><b>sock.txlen</b></font>) is
//found to be less than the threshold that was preset through the <font color="maroon"><b>sock.notifysent </b></font>method. This event may
//be generated only after the <font color="maroon"><b>sock.notifysent</b></font> method was used. <br><br>
//Your application needs to use the <font color="maroon"><b>sock.notifysent</b></font> method EACH TIME it wants to cause the 
//<font color="teal"><b>on_sock_data_sent </b></font>event generation for a particular socket. <br><br>
//When the event handler for this event is entered the <font color="maroon"><b>sock.num  </b></font>is automatically switched to the port on
//which this event was generated. Please, remember that uncommitted data in the TX buffer is not taken into account for the 
//<font color="teal"><b>on_sock_data_sent </b></font>event generation.
//--------------------------------------------------------------------
//<b>EVENT of the sock object. </b><br><br> 
//Notifies your program that the TCP packet of a certain size has arrived.
//<br><br>
//The len argument carries packet length. This event is only generated when
//<font color="maroon"><b>sock.splittcppackets</b></font>= <font color="olive"><b>1- YES </b></font>and
//<font color="maroon"><b>sock.inbandcommands</b></font>= <font color="olive"><b>0- DISABLED</b></font>.
//<br><br>
//Notice that only new data, never transmitted before, is counted. If the packet is a retransmission then this event won't be generated. Also,
//if some part of packet's data is a retransmission and some part is new then only the length of the new data will be reported. This way your
//program can maintain correct relationship between data lengths reported by this event and actual data in the RX buffer.
//<br><br>
//Multiple
//<font color="olive"><b>on_sock_tcp_packet_arrival </b></font>
//events may be waiting in the event queue. For this reason the doevents statement will be skipped (not executed) if encountered within the event handler
//for this event or the body of any procedure in the related call chain.
//--------------------------------------------------------------------
//**************************************************************************************************
//       STOR (Storage system for "settings") object
//**************************************************************************************************
//The stor object provides access to the non-volatile (EEPROM) memory in which your application can store data that
//must not be lost when the device is switched off. <br><br>
//Using this object you can also access and change the MAC address of the device (be careful with that!). 
//--------------------------------------------------------------------
stor.getdata = function (startaddr, len) { };
//<b>METHOD. </b><br><br> 
//Reads up to len number of bytes from the EEPROM starting from address startaddr (addresses are counted from 1).
//Actual amount of extracted data is also limited by the capacity of the receiving variable and the starting address.<br><br>
//EEPROM memory capacity can be checked through the <font color="maroon"><b>stor.size </b></font>read-only property. Notice that when the 
//<font color="maroon"><b>stor.getdata </b></font>executes, an offset equal to the value of <font color="maroon"><b>stor.base </b></font>is 
//added to the startaddr. <br><br>
//For example, by default, the <font color="maroon"><b>stor.base </b></font>is 9. Therefore, if you do <font color="maroon"><b>
//stor.getdata</b></font>(1,3) you are actually reading the data starting from physical EEPROM location 9. First 8 bytes of EEPROM are used to
//store the MAC address. <br><br>
//If you set the <font color="maroon"><b>stor.base </b></font>to 1 you will be able to access the EEPROM right from the physical address 0 and
//change the MAC if necessary.<br><br>
//Note: MAC address stored in the EEPROM has a certain formatting- see platform documentation for details.
//--------------------------------------------------------------------
stor.setdata = function (datatoset, startaddr) { };
//<b>METHOD. </b><br><br> 
//Writes data from the datatoset string into the EEPROM, starting from the address startaddr (addresses are counted from 1). Returns actual 
//number of bytes written into the EEPROM. Hence, the operation has completed successfully if the value returned by this method equals the 
//length of the datatoset string. <br><br>
//If this is not the case then the write has (partially) failed and there may be two reasons for this: physical EEPROM failure or invalid
//startaddr (too close to the end of memory to save the entire string). <br><br>
//EEPROM memory capacity can be checked through the <font color="maroon"><b>stor.size </b></font>read-only property. Notice that when the 
//<font color="maroon"><b>stor.setdata </b></font>executes, an offset equal to the value of <font color="maroon"><b>stor.base </b></font>is 
//added to the startaddr. <br><br>
//For example, by default, the <font color="maroon"><b>stor.base </b></font>is 8. Therefore, if you do <font color="maroon"><b>
//stor.setdata</b></font>("ABC",1) you are actually saving the data starting from physical EEPROM location 9. First 8 bytes of EEPROM are 
//used to store the MAC address and this mechanism prevents your program from overriting it by mistake. <br><br>
//On the other hand, if you want to change MAC, set the <font color="maroon"><b>stor.base </b></font>to 1- this way you will be able to write 
//to EEPROM starting from physical address 1.<br><br>
//Note: if you change the MAC address this change will only take effect after device reboot. This is the only time when the device loads its MAC
//address from the EEPROM into the Ethernet controller. MAC address stored in the EEPROM has a certain formatting- see platform documentation for 
//details.
//--------------------------------------------------------------------
Object.defineProperty(stor, 'base', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (WORD), DEFAULT VALUE= 8. </b><br><br>
//Returns the base address of the EEPROM from which the area available to your application starts. By default, the base address is 9 -- just 
//above the special configuration area that stores MAC address of the device (8 bytes are needed for that).<br><br>
//Default value of 9 makes sure that your application won't overwrite MAC by mistake. When you are accessing EEPROM memory using 
//<font color="maroon"><b>stor.setdata </b></font>or <font color="maroon"><b>stor.getdata </b></font>methods, you specify the start address.
//Actual physical address you access is start_address+<font color="maroon"><b>stor.base</b></font>. <br><br>
//If your application needs to change the MAC address you can set the <font color="maroon"><b>stor.base </b></font>to 1- this way you will have
//access to the entire memory.<br><br>
//Also see <font color="maroon"><b>stor.size</b></font>.
//--------------------------------------------------------------------
Object.defineProperty(stor, 'size', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD), DEFAULT VALUE= "actual_EEPROM_capacity-8" </b><br><br>
//Returns total EEPROM memory capacity (in bytes) for the current device. First 8 bytes of the EEPROM are used by the special configuration
//section (on this platform it occupies 8 bytes and stores MAC address of the device). By default, special configuration area is not accessible
//to the application and is excluded from memory capacity reported by <font color="maroon"><b>stor.size</b></font>.<br><br>
//For example, if the EEPROM capacity is 2048 bytes, the <font color="maroon"><b>stor.size </b></font>will return 2040 by default.
//At the same time, the default value of <font color="maroon"><b>stor.base </b></font>property will be  9, meaning that the EEPROM locations 1-8 
//are occupied by the special configuration area. <br><br>
//If you set the <font color="maroon"><b>stor.base </b></font>to 1 (for instance, to edit the MAC address), the <font color="maroon"><b>stor.size 
//</b></font>will show the capacity of 2048. In other words, the number this property returns is actual_EEPROM_capacity-
//<font color="maroon"><b>stor.base</b></font>+1.
//**************************************************************************************************
//       SYS (System) object
//**************************************************************************************************
//--------------------------------------------------------------------
Object.defineProperty(sys, 'limitbuffersize', {
    get() { return 0; },
    set() { }
});
//--------------------------------------------------------------------
//<b>EVENT of the sys object. </b><br><br> First event to be generated after your devices boots up. Typically, initialization code for
//your application is placed here.//**************************************************************************************************
//       IO (Input/output) object
//**************************************************************************************************
Object.defineProperty(io, 'intcheck', {
    get() { return 0; },
    set() { }
});
//**************************************************************************************************
//       SYS (System) object
//**************************************************************************************************
//This is the system object that loosely combines "general system" stuff such as initialization (boot) event, buffer
//management, system timer, and some other miscellaneous properties and methods.
//--------------------------------------------------------------------
//<b>EVENT of the sys object. </b><br><br> Periodic event that is generated at intervals defined by the <font color="maroon"><b>sys.onsystimerperiod </b></font>property.
//<br><br>
//Multiple <font color="teal"><b>on_sys_timer </b></font> 
//events may be waiting in the event queue. Using doevents statement in the event handler for this event or the body of any procedure in the related
//call chain may lead to the skipping (loss) of identical events waiting in the queue. This will happen when the 
//<font color="teal"><b>on_sys_timer </b></font>
//event is taken off the queue in the cause of the doevents execution related to the same event taken off the queue earlier.
//This is usually not a problem since this event is generated periodically anyway.
//<br><br>
//The <font color="teal"><b>on_sys_timer </b></font>
//event is not generated when the program execution is PAUSED (in debug mode).
//--------------------------------------------------------------------
//<b>PLATFORM CONSTANT. </b><br><br> 
//Debugging is not possible, application execution starts immediately after device powers up. Severe errors
//such as "divizion by zero" are ignored and do not stop execution.
//<b>PLATFORM CONSTANT. </b><br><br> 
//Debug mode in which it is possible to cross-debug the application (under the control of TIDE software). 
//Application execution is not started automatically after the power up. Severe errors such as "divizion by 
//zero" halt execution.
Object.defineProperty(sys, 'runmode', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (ENUM, BYTE). </b><br><br>
//Returns current run (execution) mode: <br><br>
//<font color="olive"><b>0- PL_SYS_MODE_RELEASE </b></font>(release mode),<br> <font color="olive"><b>1- PL_SYS_MODE_DEBUG </b></font> 
//(debug mode).
//--------------------------------------------------------------------
//<b>PLATFORM CONSTANT. </b><br><br> The most recent reset was a self-reset.
//<b>PLATFORM CONSTANT. </b><br><br> The most recent reset was not a self-reset.
//or power cycle).
Object.defineProperty(sys, 'resettype', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (ENUM, BYTE). </b><br><br>
//Returns the type of the most recent hardware reset:<br><br><font color="olive"><b>0- PL_SYS_RESET_TYPE_INTERNAL </b></font>(internal 
//reset caused  by "self-reboot" of the CPU -- through TIDE command or <font color="maroon"><b>sys.reboot </b></font> execution),<br><font 
//color="olive"><b>1- PL_SYS_RESET_TYPE_EXTERNAL </b></font> (caused by power-cycling of the device or applying reset pulse to the RST line).
//--------------------------------------------------------------------
//<b>PLATFORM CONSTANT. </b><br><br> The most recent reset was a self-reset.
//<b>PLATFORM CONSTANT. </b><br><br> The most recent reset was caused by the watchdog timeout.
//<b>PLATFORM CONSTANT. </b><br><br> The most recent reset was a power-up/power-down reset.
//<b>PLATFORM CONSTANT. </b><br><br> The most recent reset was a brown-out reset.
//<b>PLATFORM CONSTANT. </b><br><br> The most recent reset was initiated from the RST pin.
Object.defineProperty(sys, 'extresettype', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (BYTE, enum pl_sys_ext_reset_type). </b><br><br>
//--------------------------------------------------------------------
Object.defineProperty(sys, 'totalbuffpages', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD). </b><br><br>
//Returns the total amount of memory pages available for buffers (one page= 256 bytes). This is calculated as total available variable memory
//(RAM) minus whatever is required to store variables of the current project. <br><br>
//See also <font color="maroon"><b>sys.buffalloc </b></font> and <font color="maroon"><b>sys.freebuffpages</b></font>.
//--------------------------------------------------------------------
Object.defineProperty(sys, 'freebuffpages', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD). </b><br><br>
//Returns the number of free (not yet allocated) buffer pages (one page= 256 bytes). Only changes after the <font color="maroon"><b>
//sys.buffalloc </b></font> method is used. Preparatory methods like <font color="maroon"><b>ser.rxbuffrq </b></font>do not influence what 
//this property returns. <br><br>
//See also <font color="maroon"><b>sys.totalbuffpages</b></font>.
//--------------------------------------------------------------------
sys.halt = function () {
    debugger;
};
//<b>METHOD. </b><br><br>
//Stops your program execution (halts VM). In the debug mode (<font color="maroon"><b>sys.runmode</b></font>= <font color="olive"><b>
//1- PL_SYS_MODE_DEBUG</b></font>) causes the same result as when you press PAUSE in TIDE during the debug session. <br><br>
//In the release mode (<font color="maroon"><b>sys.runmode</b></font>= <font color="olive"><b>0- PL_SYS_MODE_RELEASE</b></font>) causes the 
//device to halt (stop) execution. <br><br>
//Once this method has been used, there is no way for your device to resume execution on its own. <br><br>
//See also <font color="maroon"><b>sys.reboot</b></font>.
//--------------------------------------------------------------------
sys.reboot = function () { };
//<b>METHOD. </b><br><br> 
//Causes your device to reboot through internal reset. After the device reboots it will behave as after any other reboot: enter PAUSE 
//mode if your program was compiled for debugging, or start execution if the program was compiled for release. <br><br>
//The PLL mode will change after the reboot if you requested the changed through <font color="maroon"><b>sys.newpll </b></font>method.<br><br>
//See also <font color="maroon"><b>sys.currentpll</b></font>, <font color="maroon"><b>sys.runmode</b></font>,
//<font color="maroon"><b>sys.resettype</b></font>, and <font color="maroon"><b>sys.halt</b></font>.
//--------------------------------------------------------------------
sys.buffalloc = function () { };
//<b>METHOD. </b><br><br>
//Allocates buffer memory as previously requested by "buffrq" methods of individual objects (such as <font color="maroon"><b>
//ser.rxbuffrq</b></font>).<br><br>
//This method takes significant amount of time (100s of milliseconds) to execute, during which time the device cannot receive network packets,
//serial data, etc. For certain interfaces like serial ports some incoming data could be lost. <br><br>
//Buffer (re)allocation for a specific object will only work if the corresponding object or part of the object to which this buffer belongs is 
//idle. "Part" refers to a particular serial port of the ser object, or particular socket of the sock object, etc. to which the buffer you are
//trying to change belongs. <br><br>
//"Idle" means different things for different objects: <font color="maroon"><b>ser.enabled</b></font>= <font color="olive"><b>0- NO </b></font> 
//for the serial port, <font color="maroon"><b> sock.statesimple</b></font>=  <font color="olive"><b>0- PL_SSTS_CLOSED </b></font> for the 
//socket, etc.
//--------------------------------------------------------------------
Object.defineProperty(sys, 'version', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (STRING). </b><br><br>
//Returns firmware (TiOS) version string. Example: "EM1000-1.20.00".
//--------------------------------------------------------------------
Object.defineProperty(sys, 'timercount', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD). </b><br><br>
//Returns the time (in half-second intervals) elapsed since the device powered up. Once this timer reaches 65535 it rolls over to 0.<br><br>
//See also <font color="teal"><b>on_sys_timer </b></font> event.
//--------------------------------------------------------------------
Object.defineProperty(sys, 'timercount32', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (DWORD). </b><br><br>
//Returns the time (in half-second intervals) elapsed since the device powered up. Once this timer reaches &hFFFFFFFF it rolls over to 0.<br><br>
//See also <font color="teal"><b>on_sys_timer </b></font> event.
//--------------------------------------------------------------------
Object.defineProperty(sys, 'timercountms', {
    get() { return 0; },
    set() { }
});
//<b> PROPERTY (DWORD). </b><br><br>
//--------------------------------------------------------------------
Object.defineProperty(sys, 'onsystimerperiod', {
    get() { return 50; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE= 50 (0.5 seconds). </b><br><br>
//Defines, in 10ms increments, the period at which the <font color="teal"><b>on_sys_timer </b></font> event will be generated.
//--------------------------------------------------------------------
Object.defineProperty(sys, 'serialnum', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (STRING). </b><br><br>
//Returns the 12-byte or 128-byte string containing the serial number of the device.
//<br><br>
//In the absense of the flash IC, the 12-byte processor ID serves as a serial number. This is a preprogrammed, unalterable ID string.
//Using <font color="maroon"><b>sys.setserialnum </b></font> won't work. 
//<br><br>
//When the flash is installed the 128-byte serial number comes from the security register of the flash IC. 
//The first 64 bytes of the security register are preprogrammed with a serial number,
//and remaining 64 bytes are one-time programmable. Use the
//<font color="maroon"><b>sys.setserialnum </b></font>
//method to set the data.
//--------------------------------------------------------------------
sys.setserialnum = function (str) { };
//<b>METHOD. </b><br><br>
//Sets the programmable portion (64 bytes) of the device's 128-byte serial number. Returns 
//<font color="olive"><b>0- OK </b></font>if completed successfully, or 
//<font color="olive"><b>1- NG </b></font>if this operation failed.
//<br><br>
//The serial number is stored in the security register of the flash IC. Older generation of flash ICs used in our devices did not have the security register. This method will return 
//<font color="olive"><b>1- NG </b></font>if you attempt to set the serial number of the device that does not have the security register.
//<br><br>
//For the method to work, the input string must be exactly 64 bytes in length, otherwise 
//<font color="olive"><b>1- NG </b></font>will be returned. The security register can only be programmed once.  Attempting to program it again will fail (again, with 
//<font color="olive"><b>1- NG </b></font>code).
//<br><br>
//Note that using this method disrupts the operation of the flash memory.
//The operation uses buffer 1 of the flash IC for temporary data storage, so invoking this method will alter the buffer contents.
//To prevent potential data errors, invoking the method sets fd.ready= 
//<font color="olive"><b>0- NO </b></font>automatically.
//<br><br>
//The Entire 128-byte serial number can be obtained through the <font color="maroon"><b>sys.serialnum </b></font>R/O property.
//--------------------------------------------------------------------
sys.debugprint = function (str) {
    console.log(str);
};
//<b>METHOD. </b><br><br>
//Sends (prints) a string to the TIDE's console output.
//<br><br>
//This method only works when the
//<font color="maroon"><b>sys.runmode</b></font>= <font color="olive"><b>1- PL_SYS_MODE_DEBUG</b></font>.
//The method allows you to trace the execution of your debug application by
//printing messages in the console output pane of TIDE. 
//--------------------------------------------------------------------
//--------------------------------------------------------------------
//--------------------------------------------------------------------
//--------------------------------------------------------------------
sys.sleep = function () { };
//--------------------------------------------------------------------
sys.stop = function () { };
//--------------------------------------------------------------------
sys.standby = function () { };
//--------------------------------------------------------------------
Object.defineProperty(sys, 'wdenabled', {
    get() { return 0; },
    set() { }
});
//--------------------------------------------------------------------
Object.defineProperty(sys, 'wdautoreset', {
    get() { return 0; },
    set() { }
});
//--------------------------------------------------------------------
Object.defineProperty(sys, 'wdperiod', {
    get() { return 0; },
    set() { }
});
//--------------------------------------------------------------------
sys.wdreset = function () { };
//--------------------------------------------------------------------
//<b>PLATFORM CONSTANT. </b><br><br> The slowest execution speed.
//<b>PLATFORM CONSTANT. </b><br><br> Medium execution speed.
//<b>PLATFORM CONSTANT. </b><br><br> Full execution speed.
Object.defineProperty(sys, 'speed', {
    get() { return 0; },
    set() { }
});
//--------------------------------------------------------------------
Object.defineProperty(sys, 'hsclock', {
    get() { return 0; },
    set() { }
});
//--------------------------------------------------------------------
Object.defineProperty(sys, 'wakeupperiod', {
    get() { return 0; },
    set() { }
});
//--------------------------------------------------------------------
//--------------------------------------------------------------------
sys.getexceptioninfo = function (hfsr, cfsr, lr, pc, current_lr) { };
//--------------------------------------------------------------------
sys.causeexception = function () { };
//--------------------------------------------------------------------
Object.defineProperty(sys, 'monversion', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (STRING). </b><br><br>
//Returns the version of the Monitor/Loader.
//--------------------------------------------------------------------
Object.defineProperty(sys, 'userbuffpages', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD). </b><br><br>
//--------------------------------------------------------------------
function sin(angle) { }
//<b>PLATFORM SYSCALL. </b><br><br>
//Calculates the sin of angle. Angle is specified in degrees
//--------------------------------------------------------------------
function asin(x) { }
//<b>PLATFORM SYSCALL. </b><br><br>
//Calculates the arc sin. Return value angle is in degrees
//--------------------------------------------------------------------
function cos(angle) { }
//<b>PLATFORM SYSCALL. </b><br><br>
//Calculates the cos of angle. Angle is specified in degrees
//--------------------------------------------------------------------
function acos(x) { }
//<b>PLATFORM SYSCALL. </b><br><br>
//Calculates the arc cos. Return value angle is in degrees
//--------------------------------------------------------------------
function tan(angle) { }
//<b>PLATFORM SYSCALL. </b><br><br>
//Calculates the tan of angle. Angle is specified in degrees
//--------------------------------------------------------------------
function atan(x) { }
//<b>PLATFORM SYSCALL. </b><br><br>
//Calculates the arc tan. Return value angle is in degrees
//--------------------------------------------------------------------
function sqrt(x) { }
//<b>PLATFORM SYSCALL. </b><br><br>
//Calculates the square root.
//--------------------------------------------------------------------
function atan2(y, x) { }
//<b>PLATFORM SYSCALL. </b><br><br>
//Calculates the square root.
//**************************************************************************************************
//       NET (Ethernet network) object
//**************************************************************************************************
//The net object represents an Ethernet interface of your device. This object only specifies various parameters related
//to the Ethernet interface (IP address, default gateway IP, netmask, etc.) and is not responsible for
//sending/transmitting network data. The latter is the job of the sock object.
//--------------------------------------------------------------------
//<b>EVENT of the net object.  </b><br><br> 
//Generated when the state of the physical link of Ethernet port changes.
//<br><br>
//This event does not "bring" with it new link state at the time of event generation. Current link state can be queried through the
//<font color="maroon"><b>net.linkstate </b></font> property.
//<br><br>
//Multiple <font color="teal"><b>on_net_link_change </b></font> 
//events may be waiting in the event queue. Using doevents statement in the event handler for this event or the body of any procedure in the related
//call chain may lead to the skipping (loss) of identical events waiting in the queue. This will happen when the 
//<font color="teal"><b>on_net_link_change </b></font>
//event is taken off the queue in the cause of the doevents execution related to the same event taken off the queue earlier.
//--------------------------------------------------------------------
//<b>EVENT of the net object. </b><br><br> 
//Generated when overflow occurs on the internal RX buffer of the Network Interface Controller (NIC) IC.
//<br><br>
//Another <font color="teal"><b>on_net_overrun </b></font>
//event is never generated until the previous one is processed.
//<br><br>
//Notice, that this event signifies the overrun of the hardware RX buffer of the NIC itself. This has nothing to do with the overrun of RX
//buffers of individual sockets (see
//<font color="teal"><b>on_sock_overrun </b></font>event).
//--------------------------------------------------------------------
Object.defineProperty(net, 'mac', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (STRING), DEFAULT VALUE= "as preset during device production". </b><br><br>
//Returns current MAC (hardware Ethernet) address of the device. You cannot use the <font color="maroon"><b>net.mac </b></font>property to set the new MAC
//address, but this address can be changed indirectly, by writing to a special area of the EEPROM (see <font color="maroon"><b>stor.setdata </b></font>and
//<font color="maroon"><b>stor.base</b></font>s).
//--------------------------------------------------------------------
Object.defineProperty(net, 'ip', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (STRING), DEFAULT VALUE= "1.0.0.1". </b><br><br>
//Sets/returns the IP address of the Ethernet interface of your device.<br><br>
//This property can only be written to when no socket is engaged in communications over the Ethernet interface, i.e. there is no socket
//for which <font color="maroon"><b>sock.statesimple </b></font>is <u>not </u> equal to <font color="olive"><b>0- PL_SSTS_CLOSED </b></font> and
//<font color="maroon"><b>sock.currentinterface</b></font>= <font color="olive"><b>1- PL_INTERFACE_NET</b></font>.
//<br><br>
//See also <font color="maroon"><b>net.gatewayip </b></font> and <font color="maroon"><b>net.netmask</b></font>.
//--------------------------------------------------------------------
Object.defineProperty(net, 'netmask', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (STRING), DEFAULT VALUE= "0.0.0.0". </b><br><br>
//Sets/returns the netmask of the Ethernet interface of your device.
//<br><br>
//This property can only be written to when no socket is engaged in communications over the Ethernet interface, i.e. there is no socket
//for which <font color="maroon"><b>sock.statesimple </b></font>is <u>not </u> equal to <font color="olive"><b>0- PL_SSTS_CLOSED </b></font> and
//<font color="maroon"><b>sock.currentinterface</b></font>= <font color="olive"><b>1- PL_INTERFACE_NET</b></font>.
//<br><br>
//See also <font color="maroon"><b>net.ip </b></font>and <font color="maroon"><b>net.gatewayip</b></font>.
//--------------------------------------------------------------------
Object.defineProperty(net, 'gatewayip', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (STRING), DEFAULT VALUE= "0.0.0.0". </b><br><br>
//Sets/returns the IP address of the default gateway for the Ethernet interface of your device.
//<br><br>
//This property can only be written to when no socket is engaged in communications over the Ethernet interface, i.e. there is no socket
//for which <font color="maroon"><b>sock.statesimple </b></font>is <u>not </u> equal to <font color="olive"><b>0- PL_SSTS_CLOSED </b></font> and
//<font color="maroon"><b>sock.currentinterface</b></font>= <font color="olive"><b>1- PL_INTERFACE_NET</b></font>.
//<br><br>
//See also <font color="maroon"><b>net.ip </b></font>and <font color="maroon"><b>net.netmask</b></font>.
//--------------------------------------------------------------------
Object.defineProperty(net, 'failure', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0- NO (no failure). </b><br><br>
//Reports whether the Network Interface Controller (NIC) IC has failed: <font color="olive"><b>0- NO </b></font>(no failure), 
//<font color="olive"><b>1- YES </b></font>(NIC failure).
//--------------------------------------------------------------------
//<b>PLATFORM CONSTANT. </b><br><br> No physical Ethernet link exists at the moment (the Ethernet port of the device is not connected to a hub).
//<b>PLATFORM CONSTANT. </b><br><br> The Ethernet port of the device is linked to a hub (or directly to another device) at 10Mbit/sec. 
//<b>PLATFORM CONSTANT. </b><br><br> The Ethernet port of the device is linked to a hub (or directly to another device) at 100Mbit/sec.
Object.defineProperty(net, 'linkstate', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0- PL_NET_LINKSTAT_NOLINK (no link). </b><br><br>
//Returns current link status of the Ethernet port of the device: <font color="olive"><b>0- PL_NET_LINKSTAT_NOLINK </b></font>(no link),
//<font color="olive"><b>1- PL_NET_LINKSTAT_10BASET </b></font>(linked at 10Mbit/s), <font color="olive"><b>2- PL_NET_LINKSTAT_100BASET 
//</b></font>(linked at 100Mbit/s).<br><br>
//See also <font color="teal"><b>on_net_link_change </b></font>event.
//**************************************************************************************************
//       PPPOE (PPPoE) object
//**************************************************************************************************
//The pppoe object represents the PPPoE interface of your device. This object only specifies the interface itself and is not responsible for
//sending/transmitting network data. The latter is the job of the sock object. The object does not perform PPPoE login and configuration either -- use
//PPPOE library for this.
//--------------------------------------------------------------------
Object.defineProperty(pppoe, 'acmac', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (STRING), DEFAULT VALUE= "0.0.0.0.0.0". </b><br><br>
//Sets/returns the MAC address of the ADSL modem (a.k.a. "access concentrator").
//<br><br>
//This property uniquely identifies the ADSL modem (access concentrator) that your device will use to access the Internet.
//--------------------------------------------------------------------
Object.defineProperty(pppoe, 'ip', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (STRING), DEFAULT VALUE= "0.0.0.0". </b><br><br>
//Sets/returns the IP address of the PPPoE interface of your device.
//<br><br>
//This property can only be written to when no socket is engaged in communications over the PPPoE interface, i.e. there is no socket
//for which <b>sock.statesimple </b>is <u>not </u> equal to 0- PL_SSTS_CLOSED and <b>sock.currentinterface</b>= 1- PL_INTERFACE_PPPOE.
//--------------------------------------------------------------------
Object.defineProperty(pppoe, 'sessionid', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (STRING), DEFAULT VALUE= 0. </b><br><br>
//Sets/returns the ID of the current PPPoE session.
//<br><br>
//Session ID is required for correct interaction between your device and ADSL modem (access concentrator). Use the PPPOE library and let it take care of this and (almost) everything else.
//**************************************************************************************************
//       IO (Input/output) object
//**************************************************************************************************
//The io. object controls the I/O lines, 8-bit I/O ports, and interrupt lines of your device.
//<br><br>
//The lists of available I/O lines, ports, and interrupt lines are platform-specific and are defined by pl_io_num, pl_io_port_num, and  pl_int_num enums.
//<br><br>
//On this platform, the I/O lines are unidirectional, i.e. you must configure each I/O line to be an output or an input, as it can't be both at the same time.
//This is done through io.enabled and io.portenabled properties.
//--------------------------------------------------------------------
//<b>EVENT of the io. object.</b><br><br>
//Generated when a change of state (from LOW to HIGH or from HIGH to LOW) on one of the enabled interrupt lines is detected.
//<br><br>
//Each bit of the linestate argument corresponds to one interrupt line in the order, in which these lines are declared in the pl_int_num enum.
//A bit value of 1 indicates that this line has CHANGED. Several lines may be reported as changed in a single call to on_io_int.
//<br><br>
//All interrupt lines are disabled by default and must be enabled individually through the io.intenabled property.
//<br><br>
//Another on_io_int event will not be generated until the previous one is processed.
//The consequence is that if the first enabled interrupt line changes its state, and then the second enabled interrupt line changes its state while the first on_io_int event hasn't yet been processed,
//then the second event will be lost.
//--------------------------------------------------------------------
Object.defineProperty(io, 'num', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0.</b><br><br>
//Sets/returns the number of the currently selected I/O line. This selection is related to io.enabled and io.state properties.
//--------------------------------------------------------------------
Object.defineProperty(io, 'portnum', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE). DEFAULT VALUE= 0.</b><br><br>
//Sets/returns the number of the currently selected 8-bit I/O port. This selection is related to io.portenabled and io.portstate properties.
//--------------------------------------------------------------------
Object.defineProperty(io, 'state', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE). DEFAULT_VALUE= 1- HIGH (typically)</b><br><br>
//For the currently selected I/O line (selection is made through the io.num property), sets/returns this line's state.
//<br><br>
//The line must be configured as output (io.enabled= 1- YES) for writes to this property to have any effect.
//--------------------------------------------------------------------
Object.defineProperty(io, 'portstate', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (BYTE). DEFAULT_VALUE= 255 (typically)</b><br><br>
//For the currently selected 8-bit I/O port (selection is made through the io.portnum property), sets/returns the states of 8 port's lines.
//<br><br>
//Each individual bit in this byte value sets/returns the state of the corresponding I/O line within the port.
//<br><br>
//Port lines must be configured as outputs (io.portenabled= 255) for writes to this property to have (full) effect.
//--------------------------------------------------------------------
Object.defineProperty(io, 'enabled', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE). DEFAULT VALUE= 0- NO.</b><br><br>
//For the currently selected I/O line (selection is made through the io.num property), sets/returns the state of the line's output buffer,
//i.e. configures the line as input (io.enabled=0) or output (io.enabled=1).
//--------------------------------------------------------------------
Object.defineProperty(io, 'portenabled', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (BYTE). DEFAULT VALUE= 0.</b><br><br>
//For the currently selected 8-bit I/O port (selection is made through the io.portnum property), sets/returns the state of the port's output buffers,
//i.e. configures individual port lines as inputs or outputs.
//<br><br>
//For each bit (line) 0 means "input" and 1 means "output".
//--------------------------------------------------------------------
io.invert = function (num) { };
//<b>METHOD.</b><br><br>
//For the I/O line specified by the num argument, inverts the state of this line (reads its current state and writes an opposite state into the output buffer).
//<br><br>
//The line must be configured as output (io.enabled= 1- YES) for this method to have any effect.
//--------------------------------------------------------------------
io.lineget = function (num) { };
//<b>METHOD.</b><br><br>
//For the I/O line specified by the num argument, returns this line's state.
//--------------------------------------------------------------------
io.lineset = function (num, state) { };
//<b>METHOD.</b><br><br>
//For the I/O line specified by the num argument, sets the state of this line's output buffer.
//The line must be configured as output (io.enabled= 1- YES) for this method to have any effect.
//--------------------------------------------------------------------
io.portget = function (num) { };
//<b>METHOD.</b><br><br>
//For the 8-bit I/O port specified by the num argument, returns this port's state.
//<br><br>
//Each individual bit of the returned value carries the state of the corresponding I/O line within the port.
//--------------------------------------------------------------------
io.portset = function (num, state) { };
//<b>METHOD.</b><br><br>
//For the 8-bit I/O port specified by the num argument, sets the state of this port's output buffers.
//<br><br>
//Each individual bit of the state argument defines the state of the corresponding I/O line within the port.
//<br><br>
//Port lines must be configured as outputs (io.portenabled= 255) for writes to this property to have (full) effect.
//--------------------------------------------------------------------
Object.defineProperty(io, 'intnum', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE). DEFAULT VALUE= 0.</b><br><br>
//Sets/returns the number of the currently selected interrupt line. This selection is related to the io.intenebled property.
//--------------------------------------------------------------------
Object.defineProperty(io, 'intenabled', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE). DEFAULT VALUE= 0- NO.</b><br><br>
//For the currently selected interrupt line (selection is made through the io.intnum property), enables/disables on_io_int event generation for this line.
//**************************************************************************************************
//       BEEP (Beeper) object
//**************************************************************************************************
//The beep. object allows you to "play" sound patters using a buzzer attached to the CO pin of your device.
//--------------------------------------------------------------------
//<b>EVENT of the beep object.</b><br><br> 
//Generated when a pattern finishes playing. This can only happened for "non-looped" patterns.
//<br><br>
//The event won't be generated if the current pattern is superseded (overwritten) by a new call to beep.play.
//--------------------------------------------------------------------
//<b>PLATFORM CONSTANT. Tells the beep.play method that the new pattern can only be loaded if no pattern is playing at the moment.
//<b>PLATFORM CONSTANT. </b><br><br> Tells the beep.play method that the new pattern can be loaded even if another pattern is currently playing.
beep.play = function (pattern, patint) { };
//<b>METHOD. </b><br><br> 
//Loads a new buzzer pattern to play.
//<br><br>
//The pattern string defines the pattern, for example: "B-B-B~*".
//<br><br>
//The meaning of characters:
//<br><br>
//'-': No sound (no square wave output).
//<br><br>
//'B' or 'b': Beep (generate square wave output).
//<br><br>
//'~': Looped pattern. This character can be inserted anywhere in the pattern string. 
//<br><br>
//'*': Double the speed of playing this pattern. Can be inserted anywhere in the pattern string. Applies to the entire string. You can use up to two * characters, meaning that you can quadruple the normal speed of the output. 
//<br><br>
//At the normal speed, each step is 200 ms long. Therefore, the step duration is 100ms when the speed is doubled (*) and 50ms when the speed is quadrupled (**).
//<br><br>
//The patint argument determines if this method's invocation is allowed to interrupt another pattern that is already playing. 
//--------------------------------------------------------------------
Object.defineProperty(beep, 'divider', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (WORD), DEFAULT VALUE= 1. </b><br><br>
//Defines the buzzer frequency (frequency of the square wave output on the CO line).
//<br><br>
//The output frequency depends on sys.currentpll and is calculated as follows (assuming full-speed operation):
//<br><br>
//F = 30'000'000 / beep.divider.
//<br><br>
//The recommended divider value for this platform is 11111.
//**************************************************************************************************
//       RTC (Real-time Counter) object
//**************************************************************************************************
//Facilitates access to the real-time counter (RTC) of the device. The RTC is an independent hardware counter that has its
//own power input. When the backup battery is installed, the RTC will continue running even when the rest of the device is
//powered off. <br><br>
//The RTC keeps track of elapsed days, minutes, and seconds, not actual date and time. This is why it is called the "counter",
//not "clock". This platform includes a set of convenient date and time conversion functions that can be used to transform RTC
//data into current weekday, date, and time (see <font color="teal"><b>weekday</b></font>, <font color="teal"><b>year</b></font>, <font color="teal"><b>month</b></font>, <font color="teal"><b>date</b></font>, <font color="teal"><b>hours</b></font>, minutes).
//--------------------------------------------------------------------
rtc.getdata = function (daycount, mincount, seconds) { };
//<b>METHOD. </b><br><br> 
//Returns current RTC data as the number of elapsed days (daycount), minutes (mincount) and seconds.
//This platform includes a set of convenient date and time conversion functions that can be used to transform "elapsed time"
//values into current date/time and back (see <font color="teal"><b>year</b></font>, <font color="teal"><b>month</b></font>, <font color="teal"><b>date</b></font>, <font color="teal"><b>weekday</b></font>, <font color="teal"><b>hours</b></font>, <font color="teal"><b>minutes</b></font>, <font color="teal"><b>daycount</b></font>, mincount, and seconds
//platform syscalls). <br><br>
//Notice, that after the device powers up and provided that the backup power was not present at all times the RTC may be in the 
//undetermined state and not work properly until the <font color="maroon"><b>rtc.setdata </b></font>method is executed at least once.
//--------------------------------------------------------------------
rtc.setdata = function (daycount, mincount, seconds) { };
//<b>METHOD. 
//</b><br><br> Presets the RTC with a number of elapsed days (daycount), minutes (mincount), and seconds. This platform includes
//a set of convenient date and time conversion functions that can be used to transform actual date into time into
//"elapsed time" values (see daycount and mincount). <br><br>
//Notice, that after the device powers up and provided that the backup power was not present at all times the RTC may be in the 
//undetermined state and not work properly until the <font color="maroon"><b>rtc.setdata </b></font>method is executed at least once.
//--------------------------------------------------------------------
Object.defineProperty(rtc, 'running', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (ENUM, BYTE). </b><br><br> 
//Returns current RTC state: <font color="olive"><b>0- NO </b></font>(RTC not running), <font color="olive"><b>1- YES </b></font>(RTC is running). 
//When this property returns <font color="olive"><b>0- NO </b></font>this typically is the sign of a hardware malfunction (for instance, 
//RTC crystal failure). <br><br>
//When the RTC is powered up after being off (that is, device had not power AND no backup power for a period of time), it may not work 
//correctly until you set it using <font color="maroon"><b>rtc.setdata </b></font>method. <font color="maroon"><b> Rtc.running </b></font>
//cannot be used to reliably check RTC state in this situation.
//--------------------------------------------------------------------
//--------------------------------------------------------------------
//**************************************************************************************************
//       LCD object
//**************************************************************************************************
//The lcd object is for operating a display panel. 
//--------------------------------------------------------------------
Object.defineProperty(lcd, 'backcolor', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (WORD), DEFAULT VALUE= 0.</b><br><br>
//Specifies current background color.
//<br><br>
//The background color is used when drawing filled rectangles (
//<font color="maroon"><b>lcd.filledrectangle</b></font>) and performing fills (
//<font color="maroon"><b>lcd.fill</b></font>).  Property value interpretation depends on the currently selected controller/panel.
//<br><br>
//Only the <font color="maroon"><b>lcd.bitsperpixel </b></font> lower bits of this value will be relevant. All higher bits will be ignored.
//<br><br>
//For monochrome and grayscale controllers/panels (
//<font color="maroon"><b>lcd.paneltype</b></font>= 
//<font color="olive"><b>0- PL_LCD_PANELTYPE_GRAYSCALE</b></font>), this value will relate to the brightness of the pixel. For color panels/controllers (
//<font color="maroon"><b>lcd.paneltype</b></font>= 
//<font color="olive"><b>1- PL_LCD_PANELTYPE_COLOR</b></font>) the value is composed of three fields -- one each for the red, green, and blue "channels".  Check 
//<font color="maroon"><b>lcd.redbits</b></font>, 
//<font color="maroon"><b>lcd.greenbits</b></font>, and 
//<font color="maroon"><b>lcd.bluebits </b></font>properties to see how the fields are combined into the color word.
//<br><br>See also: 
//<font color="maroon"><b>lcd.forecolor</b></font>, 
//<font color="maroon"><b>lcd.linewidth</b></font>.
//--------------------------------------------------------------------
Object.defineProperty(lcd, 'bitsperpixel', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (BYTE).</b><br><br>
//Returns the number of bits available for each pixel of the currently selected controller/panel.
//<br><br>
//For monochrome controllers/panels (see 
//<font color="maroon"><b>lcd.paneltype</b></font>) the 
//<font color="maroon"><b>lcd.bitsperpixel </b></font> will return 1, that is, the pixel can only be on or off.
//For grayscale panels, this value will be >1, which indicates that each pixel can be set to a number of brightness levels. For example, if the 
//<font color="maroon"><b>lcd.bitsperpixel</b></font>= 4, then each pixel's brightness can be adjusted in 16 steps.
//<br><br>
//For color panels, this property reflects the combined number of red, green, and blue bits available for each pixel (see 
//<font color="maroon"><b>lcd.redbits</b></font>, 
//<font color="maroon"><b>lcd.greenbits</b></font>, and 
//<font color="maroon"><b>lcd.bluebits</b></font>). 
//<br><br>
//The number of bits per pixel affects how 
//<font color="maroon"><b>lcd.forecolor</b></font>, 
//<font color="maroon"><b>lcd.backcolor</b></font>, and 
//<font color="maroon"><b>lcd.setpixel </b></font>are interpreted. Also, the output produced by 
//<font color="maroon"><b>lcd.bmp </b></font>depends on this property.
//--------------------------------------------------------------------
Object.defineProperty(lcd, 'bluebits', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD).</b><br><br>
//A 16-bit value packing two 8-bit parameters: number of "blue" bits per pixel (high byte) and the position of the least significant blue bit within the color word (low byte).
//<br><br>
//The value of this property depends on the currently selected controller/panel. This property is only relevant for color panels (
//<font color="maroon"><b>lcd.paneltype</b></font>= 
//<font color="olive"><b>1- PL_LCD_PANELTYPE_COLOR</b></font>).
//<br><br>
//Together with <font color="maroon"><b>lcd.greenbits </b></font>and 
//<font color="maroon"><b>lcd.redbits</b></font>, this property allows you to understand the composition of a color word used in 
//<font color="maroon"><b>lcd.setpixel</b></font>, 
//<font color="maroon"><b>lcd.forecolor</b></font>, and 
//<font color="maroon"><b>lcd.backcolor</b></font>.
//--------------------------------------------------------------------
lcd.bmp = function (offset, x, y, x_offset, y_offset, maxwidth, maxheight) { };
//<b>METHOD. </b><br><br>
//Displays a portion of or full image stored in a BMP file. Returns 
//<font color="olive"><b>0- OK </b></font>if the image was processed successfully, or 
//<font color="olive"><b>1- NG </b></font>if unsupported or invalid file format was detected.
//<br><br>
//<b>offset</b>- Offset within the compiled binary of your application at which the BMP file is stored. To obtain the offset, open the BMP file 
//with romfile.open, then read the offset of this file from the 
//<font color="maroon"><b>romfile.offset </b></font>R/O property. The BMP file must be present in your project for this to work (see how to add a file).
//<br><br>
//<b>x</b> -- X coordinate of the top-left point of the image position on the screen. Value range is 0 to 
//<font color="maroon"><b>lcd.width</b></font>-1.
//<br>
//<b>y</b> -- Y coordinate of the top-left point of the image position on the screen. Value range is 0 to 
//<font color="maroon"><b>lcd.height</b></font>-1.
//<br>
//<b>x_offset</b> -- Horizontal offset within the BMP file marking the top-left corner of the image portion to be displayed.
//<br>
//<b>y_offset</b> -- Vertical offset within the BMP file marking the top-left corner of the image portion to be displayed.
//<br>
//<b>maxwidth</b> -- Maximum width of the image portion to be displayed. Actual width of the output will be defined by the total width of the image and specified x_offset.
//<br>
//<b>maxheight</b> -- Maximum height of the image portion to be displayed. Actual height of the output will be defined by the total height of the image and specified y_offset.
//<br><br>
//Note that only 2-, 16-, and 256-color modes are currently supported and the 
//<font color="maroon"><b>lcd.bmp </b></font>will return 
//<font color="olive"><b>1- NG </b></font>if you try to display any other type of BMP file. Compressed BMP files will be rejected too.
//--------------------------------------------------------------------
lcd.bmpfromfile = function (ignored_parameter, x, y, x_offset, y_offset, maxwidth, maxheight) { };
//--------------------------------------------------------------------
Object.defineProperty(lcd, 'enabled', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0- NO (disabled).</b><br><br>
//Specifies whether the display panel is enabled.
//<br><br>
//Several properties -- 
//<font color="maroon"><b>lcd.iomapping</b></font>, 
//<font color="maroon"><b>lcd.width</b></font>, 
//<font color="maroon"><b>lcd.height</b></font>, 
//<font color="maroon"><b>lcd.inverted</b></font>, 
//<font color="maroon"><b>lcd.rotated </b></font>-- can only be changed when the display panel is disabled.
//<br><br>
//When you set this property to 
//<font color="olive"><b>1- YES</b></font>, the controller of the panel is initialized and enabled. This will only work if 
//your display is properly connected, correct display type is selected in your project, 
//<font color="maroon"><b>lcd.iomapping </b></font>is set property, and necessary I/O lines are configured as outputs. The 
//<font color="maroon"><b>lcd.error </b></font>R/O property will indicate <font color="olive"><b>1- YES </b></font>if there was a problem enabling the display.
//<br><br>
//Setting the property to 
//<font color="olive"><b>0- NO </b></font>disables the controller/panel.
//--------------------------------------------------------------------
Object.defineProperty(lcd, 'error', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0- NO (no error detected).</b><br><br>
//Indicates whether controller/panel I/O error has been detected.
//<br><br>
//The lcd. object will detect a malfunction (or absence) of the controller/panel that is expected to be connected.
//If the display is not properly connected, or the lcd. object is not set up property to work with this display, the 
//<font color="maroon"><b>lcd.error </b></font>will be set to 
//<font color="olive"><b>1- YES </b></font>on attempt to enable the display (set 
//<font color="maroon"><b>lcd.enabled</b></font>= 
//<font color="olive"><b>1- YES</b></font>).
//--------------------------------------------------------------------
lcd.fill = function (x, y, width, height) { };
//<b>METHOD. </b><br><br>
//Paints the area with the "pen" color (
//<font color="maroon"><b>lcd.forecolor</b></font>).
//<br><br>
//<b>x</b> -- X coordinate of the top-left point of the area to be painted. Value range is 0 to 
//<font color="maroon"><b>lcd.width</b></font>-1.
//<br>
//<b>y</b> -- Y coordinate of the top-left point  of the area to be painted. Value range is 0 to 
//<font color="maroon"><b>lcd.height</b></font>-1.
//<br>
//<b>width</b> -- Width of the paint area in pixels.
//<br>
//<b>height</b> -- Height of the paint area in pixels.
//<br><br>
//The display panel must be enabled (
//<font color="maroon"><b>lcd.enabled</b></font>= 
//<font color="olive"><b>1- YES</b></font>) for this method to work.
//<br><br>
//See also: 
//<font color="maroon"><b>lcd.line</b></font>, 
//<font color="maroon"><b>lcd.verline</b></font>, 
//<font color="maroon"><b>lcd.horline</b></font>, 
//<font color="maroon"><b>lcd.rectangle</b></font>,
//<font color="maroon"><b>lcd.filledrectangle</b></font>.
//--------------------------------------------------------------------
lcd.filledrectangle = function (x1, y1, x2, y2) { };
//<b>METHOD. </b><br><br>
//Draws a filled rectangle.
//<br><br>
//<b>x1</b> -- X coordinate of the first point. Value range is 0 to 
//<font color="maroon"><b>lcd.width</b></font>-1.
//<br>
//<b>y1</b> -- Y coordinate of the first point. Value range is 0 to 
//<font color="maroon"><b>lcd.height</b></font>-1.
//<br>
//<b>x2</b> -- X coordinate of the second point. Value range is 0 to 
//<font color="maroon"><b>lcd.width</b></font>-1.
//<br>
//<b>y2</b> -- Y coordinate of the second point. Value range is 0 to 
//<font color="maroon"><b>lcd.height</b></font>-1.
//<br><br>
//The border is drawn with the specified line width (
//<font color="maroon"><b>lcd.linewidth</b></font>) and "pen" color (
//<font color="maroon"><b>lcd.forecolor</b></font>).
//The rectangle is then filled using the background color (
//<font color="maroon"><b>lcd.backcolor</b></font>). Setting the 
//<font color="maroon"><b>lcd.linewidth </b></font>to 0 will create a rectangle with no border -- basically, a filled area.
//<br><br>
//The display panel must be enabled (
//<font color="maroon"><b>lcd.enabled</b></font>= 
//<font color="olive"><b>1- YES</b></font>) for this method to work. 
//<br><br>
//See also: 
//<font color="maroon"><b>lcd.line</b></font>, 
//<font color="maroon"><b>lcd.verline</b></font>, 
//<font color="maroon"><b>lcd.horline</b></font>, 
//<font color="maroon"><b>lcd.rectangle</b></font>, 
//<font color="maroon"><b>lcd.fill</b></font>.
//--------------------------------------------------------------------
Object.defineProperty(lcd, 'fontheight', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (BYTE), DEFAULT VALUE= 0.</b><br><br>
//Returns the maximum height, in pixels, of characters in the currently selected font.
//<br><br>
//This property will only return meaningful data after you select a font using the 
//<font color="maroon"><b>lcd.setfont </b></font>method.
//<br><br>
//See also: 
//<font color="maroon"><b>lcd.fontpixelpacking</b></font>.
//--------------------------------------------------------------------
Object.defineProperty(lcd, 'fontpixelpacking', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0- PL_VERTICAL (vertically adjacent pixels are packed into each byte).</b><br><br>
//Indicates how pixels are packed into bytes in a currently selected font: 
//<font color="olive"><b>0- PL_VERTICAL </b></font>when vertically adjacent pixels are packed into each byte, 
//<font color="olive"><b>1- PL_HORIZONTAL </b></font>when horizontally adjacent pixels are packed into each byte.
//<br><br>
//Display controllers/panels can have vertical or horizontal pixel packing (see 
//<font color="maroon"><b>lcd.pixelpacking</b></font>).
//The speed at which you can output the text onto the screen is improved when the 
//<font color="maroon"><b>lcd.pixelpacking </b></font>and 
//<font color="maroon"><b>lcd.fontpixelpacking </b></font>have the same value,
//i.e. controller memory pixels and font encoding are "aligned". Our font files are typically available both in vertical and horizontal pixel packing.
//Pick the right file for your controller/panel.
//<br><br>
//This property will only return meaningful data after you select a font using the 
//<font color="maroon"><b>lcd.setfont </b></font>method.
//<br><br>
//See also: 
//<font color="maroon"><b>lcd.fontheight</b></font>.
//--------------------------------------------------------------------
Object.defineProperty(lcd, 'forecolor', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (WORD), DEFAULT VALUE= 65535 (&hFFFF).</b><br><br>
//Specifies current "pen" (drawing) color.
//<br><br>
//Pen color is used when drawing lines (
//<font color="maroon"><b>lcd.line</b></font>, 
//<font color="maroon"><b>lcd.verline</b></font>, 
//<font color="maroon"><b>lcd.horline</b></font>) and rectangles (
//<font color="maroon"><b>lcd.rectangle</b></font>, 
//<font color="maroon"><b>lcd.filledrectangle</b></font>), as well as displaying text (
//<font color="maroon"><b>lcd.print</b></font>, 
//<font color="maroon"><b>lcd.printaligned</b></font>). 
//<br><br>
//Property value interpretation depends on the currently selected controller/panel.
//Selection is made through the Customize Platform dialog, accessible through the Project Settings dialog.
//<br><br>
//The property is of word type, but only 
//<font color="maroon"><b>lcd.bitsperpixel </b></font> lower bits of this value will be relevant. All higher bits will be ignored.
//<br><br>
//For monochrome and grayscale controllers/panels (
//<font color="maroon"><b>lcd.paneltype</b></font>= 
//<font color="olive"><b>0- PL_LCD_PANELTYPE_GRAYSCALE</b></font>), this value will relate to the brightness of the pixel.  For color panels/controllers (
//<font color="maroon"><b>lcd.paneltype</b></font>= 
//<font color="olive"><b>1- PL_LCD_PANELTYPE_COLOR</b></font>) the value is composed of three fields -- one for the red, green, and blue "channels". Check 
//<font color="maroon"><b>lcd.redbits</b></font>, 
//<font color="maroon"><b>lcd.greenbits</b></font>, and 
//<font color="maroon"><b>lcd.bluebits </b></font>properties to see how the fields are combined into the color word.
//<br><br>
//See also: 
//<font color="maroon"><b>lcd.backcolor</b></font>, 
//<font color="maroon"><b>lcd.linewidth</b></font>.
//--------------------------------------------------------------------
lcd.getprintwidth = function (str) { };
//<b>METHOD. </b><br><br>
//Returns the width, in pixels, of the text output that will be produced if the <b>str</b> line is actually printed with the 
//<font color="maroon"><b>lcd.print </b></font>method.
//<br><br>
//This method does not produce any output on the display, it merely estimates the width of the text if it was to be printed.
//<font color="maroon"><b>Lcd.print </b></font>
//also returns the width of the text in pixels, but this data comes after the printing.
//Sometimes it is desirable to know the output width for the line of text before printing it, and this method allows you to do so.
//<br><br>
//The width calculation will be affected by the value of the 
//<font color="maroon"><b>lcd.texthorizontalspacing </b></font>property.
//--------------------------------------------------------------------
Object.defineProperty(lcd, 'greenbits', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD).</b><br><br>
//A 16-bit value packing two 8-bit parameters: number of "green" bits per pixel (high byte) and the position of the least significant green bit within the color word (low byte).
//<br><br>
//The value of this property depends on the currently selected controller/panel. This property is only relevant for color panels (
//<font color="maroon"><b>lcd.paneltype</b></font>= 
//<font color="olive"><b>1- PL_LCD_PANELTYPE_COLOR</b></font>).
//<br><br>
//Together with <font color="maroon"><b>lcd.bluebits </b></font>and 
//<font color="maroon"><b>lcd.redbits</b></font>, this property allows you to understand the composition of a color word used in 
//<font color="maroon"><b>lcd.setpixel</b></font>, 
//<font color="maroon"><b>lcd.forecolor</b></font>, and 
//<font color="maroon"><b>lcd.backcolor</b></font>.
//--------------------------------------------------------------------
Object.defineProperty(lcd, 'height', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (WORD), DEFAULT VALUE= 0.</b><br><br>
//Sets the vertical resolution of the display panel in pixels.
//<br><br>
//Set this property according to the characteristics of your display panel.
//This value is not set automatically when you select a certain controller because the capability of the controller may exceed the actual resolution of the panel,
//i.e. only "part" of the controller may be utilized.
//<br><br>
//This property can only be changed when the lcd is disabled (
//<font color="maroon"><b>lcd.enabled</b></font>= 
//<font color="olive"><b>0- NO</b></font>). 
//<br><br>
//See also: 
//<font color="maroon"><b>lcd.width</b></font>.
//--------------------------------------------------------------------
lcd.horline = function (x1, x2, y) { };
//<b>METHOD. </b><br><br>
//Draws a horizontal line.
//<br><br>
//<b>x1</b> -- X coordinate of the first point. Value range is 0 to 
//<font color="maroon"><b>lcd.width</b></font>-1.
//<br>
//<b>x2</b> -- X coordinate of the second point. Value range is 0 to 
//<font color="maroon"><b>lcd.width</b></font>-1.
//<br>
//<b>y</b> -- Y coordinates of the first and second points. Value range is 0 to 
//<font color="maroon"><b>lcd.height</b></font>-1.
//<br><br>
//The line is drawn with the specified line width (
//<font color="maroon"><b>lcd.linewidth</b></font>) and "pen" color (
//<font color="maroon"><b>lcd.forecolor</b></font>).  Drawing horizontal or vertical (
//<font color="maroon"><b>lcd.verline</b></font>) lines is more efficient than drawing generic lines (
//<font color="maroon"><b>lcd.line</b></font>), and should be used whenever possible.
//<br><br>
//The display panel must be enabled (
//<font color="maroon"><b>lcd.enabled</b></font>=
//<font color="olive"><b>1- YES</b></font>) for this method to work.
//<br><br>
//See also: 
//<font color="maroon"><b>lcd.rectangle</b></font>, 
//<font color="maroon"><b>lcd.filledrectangle</b></font>, 
//<font color="maroon"><b>lcd.fill</b></font>.
//--------------------------------------------------------------------
Object.defineProperty(lcd, 'inverted', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0- NO (not inverted, higher memory value = higher pixel brightness).</b><br><br>
//Specifies whether the image on the display panel has to be inverted: 
//<font color="olive"><b>0- NO </b></font>(normal image), 
//<font color="olive"><b>1- YES </b></font> (image must be inverted).
//<br><br>
//Set this property according to the characteristics of your display panel.
//<br><br>
//This value is not set automatically when you select a certain controller because the display characteristics cannot be detected automatically,
//as they depend on the panel and its backlight arrangement.
//<br><br>
//This property can only be changed when the display is disabled (
//<font color="maroon"><b>lcd.enabled</b></font>= 
//<font color="olive"><b>0- NO</b></font>). 
//--------------------------------------------------------------------
Object.defineProperty(lcd, 'iomapping', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (STRING), DEFAULT VALUE= "".</b><br><br>
//Defines the list of I/O lines to interface with the currently selected controller/panel.
//<br><br>
//Different controllers/panels require a different set of interface lines, and even the number of lines depends on the hardware.
//This property should contain a comma-separated list of decimal numbers that indicate which I/O lines and ports are used to connect the controller/panel to your device.
//The meaning of each number in the list is controller- and panel-specific. See the Supported Controllers section of the Manual for details.
//<br><br>
//This property can only be changed when the display is disabled (
//<font color="maroon"><b>lcd.enabled</b></font>= 
//<font color="olive"><b>0- NO</b></font>).
//--------------------------------------------------------------------
lcd.line = function (x1, y1, x2, y2) { };
//<b>METHOD. </b><br><br>
//Draws a line.
//<br><br>
//<b>x1</b> -- X coordinate of the first point. Value range is 0 to 
//<font color="maroon"><b>lcd.width</b></font>-1.
//<br>
//<b>x2</b> -- Y coordinate of the first point. Value range is 0 to 
//<font color="maroon"><b>lcd.height</b></font>-1.
//<br>
//<b>y1</b> -- X coordinate of the second point. Value range is 0 to 
//<font color="maroon"><b>lcd.width</b></font>-1.
//<br>
//<b>y2</b> -- Y coordinate of the second point. Value range is 0 to 
//<font color="maroon"><b>lcd.height</b></font>-1.
//<br><br>
//The line is drawn with the specified line width (
//<font color="maroon"><b>lcd.linewidth</b></font>) and "pen" color (
//<font color="maroon"><b>lcd.forecolor</b></font>).  Drawing horizontal (
//<font color="maroon"><b>lcd.horline</b></font>) or vertical (
//<font color="maroon"><b>lcd.verline</b></font>) lines is more efficient than drawing generic lines, and should be used whenever possible.
//<br><br>
//The display panel must be enabled (
//<font color="maroon"><b>lcd.enabled</b></font>= 
//<font color="olive"><b>1- YES</b></font>) for this method to work.
//<br><br>
//See also:  
//<font color="maroon"><b>lcd.rectangle</b></font>, 
//<font color="maroon"><b>lcd.filledrectangle</b></font>, 
//<font color="maroon"><b>lcd.fill</b></font>.
//--------------------------------------------------------------------
Object.defineProperty(lcd, 'linewidth', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (BYTE), DEFAULT VALUE= 1 (1 pixel).</b><br><br>
//Specifies current "pen" width in pixels.
//<br><br>
//Pen width is used when drawing lines (
//<font color="maroon"><b>lcd.line</b></font>, 
//<font color="maroon"><b>lcd.verline</b></font>, 
//<font color="maroon"><b>lcd.horline</b></font>) and rectangles (
//<font color="maroon"><b>lcd.rectangle</b></font>, 
//<font color="maroon"><b>lcd.filledrectangle</b></font>).
//<br><br>
//See also: 
//<font color="maroon"><b>lcd.forecolor</b></font>, 
//<font color="maroon"><b>lcd.backcolor</b></font>.
//--------------------------------------------------------------------
lcd.lock = function () { };
//<b>METHOD. </b><br><br>
//Freezes display output (on controllers/panels that support this feature).
//<br><br>
//When the display is locked, you can make changes to the display data without showing these changes on the screen.  You can then unlock the display (
//<font color="maroon"><b>lcd.unlock</b></font>) and show all the changes made at once. This usually greatly improves the display agility perception by the user.
//<br><br>
//When you execute this method for the first time, the display gets locked and the 
//<font color="maroon"><b>lcd.lockcount </b></font>R/O property changes from 0 to 1.  You can invoke 
//<font color="maroon"><b>lcd.lock </b></font>again and again, and the 
//<font color="maroon"><b>lcd.lockcount </b></font>will increase with each call to the 
//<font color="maroon"><b>lcd.lock</b></font>. This allows you to nest locks/unlocks.  The display is locked for all 
//<font color="maroon"><b>lcd.lockcount </b></font>values other than 0.
//--------------------------------------------------------------------
Object.defineProperty(lcd, 'lockcount', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (BYTE), DEFAULT VALUE= 0 (display unlocked).</b><br><br>
//Indicates the current nesting level of the display lock.
//<br><br>
//Invoking <font color="maroon"><b>lcd.lock </b></font>increases the value of this property by 1. If 255 is reached, the value does not roll over to 0 and stays at 255.
//Invoking <font color="maroon"><b>lcd.unlock </b></font>decreases the value of this property by 1. When 0 is reached, the value does not roll over to 255 and stays at 0.
//The display is locked when 
//<font color="maroon"><b>lcd.lockcount </b></font>is not at 0.
//<br><br>
//When the display is locked, you can make changes to the display data without showing these changes on the screen. You can then unlock the display and show all the changes made at once.
//This usually greatly improves the display agility perception.
//<br><br>
//Not all controllers/panels support this feature. If your display does not support locking, executing 
//<font color="maroon"><b>lcd.lock </b></font>will have no effect and 
//<font color="maroon"><b>lcd.lockcount </b></font>will always stay at 0.
//--------------------------------------------------------------------
//<b>PLATFORM CONSTANT.</b><br> Monochrome or grayscale panel/controller.
//<b>PLATFORM CONSTANT.</b><br> Color panel/controller.
Object.defineProperty(lcd, 'paneltype', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE).</b><br><br>
//Returns the type of the currently selected controller/panel: 
//<font color="olive"><b>0- PL_LCD_PANELTYPE_GRAYSCALE </b></font> for a monochrome or grayscale panel/controller, 
//<font color="olive"><b>1- PL_LCD_PANELTYPE_COLOR </b></font> for color panel/controller.
//<br><br>
//Monochrome panels/controllers only allow you to turn pixels on and off. Grayscale panels/controllers allow you to set the brightness of pixels in steps.
//The number of available steps is defined by the number of bits assigned to each pixel (see 
//<font color="maroon"><b>lcd.bitsperpixel </b></font> property).
//Finally, color panels/controllers allow you to set the brightness separately for the red, green, and blue components of each pixel.
//<font color="maroon"><b>lcd.redbits</b></font>, 
//<font color="maroon"><b>lcd.greenbits</b></font>, and 
//<font color="maroon"><b>lcd.bluebits </b></font>R/O properties will tell you how many bits there are for each color "channel". 
//<br><br>
//Panel/controller type affects how 
//<font color="maroon"><b>lcd.forecolor</b></font>, 
//<font color="maroon"><b>lcd.backcolor</b></font>, and 
//<font color="maroon"><b>lcd.setpixel </b></font>are interpreted. Also, the output produced by 
//<font color="maroon"><b>lcd.bmp </b></font>is affected by this.
//--------------------------------------------------------------------
Object.defineProperty(lcd, 'pixelpacking', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0- PL_VERTICAL (vertically adjacent pixels are packed into each byte).</b><br><br>
//Indicates how pixels are packed into controller memory for the currently selected controller/panel: 
//<font color="olive"><b>0- PL_VERTICAL </b></font>when vertically adjacent pixels are packed into each byte,
//<font color="olive"><b>1- PL_HORIZONTAL </b></font>when horizontally adjacent pixels are packed into each byte.
//<br><br>
//This property is only relevant for controllers/panels whose 
//<font color="maroon"><b>lcd.bitsperpixel </b></font> value is less than 8. In this case, 2, 4, or 8 pixels are packed into a single byte of controller memory.
//<br><br>
//This property is purely informational and largely has no influence over how you write your application. The only exception is related to working with text.
//Fonts can also have vertical or horizontal packing and the speed at which you can output the text onto the screen is improved when the 
//<font color="maroon"><b>lcd.pixelpacking </b></font>and
//<font color="maroon"><b>lcd.fontpixelpacking </b></font>have the same value, i.e. controller memory pixels and font encoding are "aligned".
//--------------------------------------------------------------------
lcd.print = function (str, x, y) { };
//<b>METHOD. </b><br><br>
//Prints a <b>str </b>line of text at <b>x</b>, <b>y </b>coordinates. Returns total width of created output in pixels.
//<br><br>
//For this method to work, a font must first be selected with the 
//<font color="maroon"><b>lcd.setfont </b></font>method. The 
//<font color="maroon"><b>lcd.textorientation </b></font>and 
//<font color="maroon"><b>lcd.texthorizontalspacing </b></font>properties affect how the text is printed.  This method always produces a single-line text output. Use 
//<font color="maroon"><b>lcd.printaligned </b></font>if you want to print several lines of text at once.
//<br><br>
//The display panel must be enabled (
//<font color="maroon"><b>lcd.enabled</b></font>= 
//<font color="olive"><b>1- YES</b></font>) for this method to work.
//<br><br>
//See also: 
//<font color="maroon"><b>lcd.getprintwidth</b></font>.
//--------------------------------------------------------------------
lcd.printaligned = function (str, x, y, width, height) { };
//<b>METHOD. </b><br><br>
//Print texts, on several lines if necessary, within a specified rectangular area. Returns total number of text lines produced.
//<br><br>
//<b>str</b> -- Text to print. Inserting ` character will create a line break.
//<br>
//<b>x</b> -- X coordinate of the top-left point of the print area. Value range is 0 to 
//<font color="maroon"><b>lcd.width</b></font>-1.
//<br>
//<b>y</b> -- Y coordinate of the top-left point of the print area. Value range is 0 to 
//<font color="maroon"><b>lcd.height</b></font>-1.
//<br>
//<b>width</b> -- Width of the print area in pixels.
//<br>
//<b>height</b> -- Height of the print area in pixels.
//<br><br>
//For this method to work, a font must first be selected with the 
//<font color="maroon"><b>lcd.setfont </b></font>method.  The 
//<font color="maroon"><b>lcd.textalignment</b></font>, 
//<font color="maroon"><b>lcd.textorientation</b></font>, 
//<font color="maroon"><b>lcd.texthorizontalspacing</b></font>, and 
//<font color="maroon"><b>lcd.textverticalspacing </b></font>properties will affect how the text is printed.
//<br><br>
//This method breaks the text into lines to stay within the specified rectangular output area. Whenever possible, text is split without breaking up the words.
//A word will be split if it is wider than the width of the print area. You can add arbitrary line brakes by inserting ` (ASCII code 96).
//<br><br>
//The display panel must be enabled (
//<font color="maroon"><b>lcd.enabled</b></font>= 
//<font color="olive"><b>1- YES</b></font>) for this method to work.
//--------------------------------------------------------------------
lcd.rectangle = function (x1, y1, x2, y2) { };
//<b>METHOD. </b><br><br>
//Draws an unfilled rectangle.
//<br><br>
//<b>x1</b> -- X coordinate of the first point. Value range is 0 to 
//<font color="maroon"><b>lcd.width</b></font>-1.
//<br>
//<b>y1</b> -- Y coordinate of the first point. Value range is 0 to 
//<font color="maroon"><b>lcd.height</b></font>-1.
//<br>
//<b>x2</b> -- X coordinate of the second point. Value range is 0 to 
//<font color="maroon"><b>lcd.width</b></font>-1.
//<br>
//<b>y2</b> -- Y coordinate of the second point. Value range is 0 to 
//<font color="maroon"><b>lcd.height</b></font>-1.
//<br><br>
//The rectangle is drawn with the specified line width (
//<font color="maroon"><b>lcd.linewidth</b></font>) and "pen" color (
//<font color="maroon"><b>lcd.forecolor</b></font>).  The display panel must be enabled (
//<font color="maroon"><b>lcd.enabled</b></font>= 
//<font color="olive"><b>1- YES</b></font>) for this method to work.
//<br><br>
//See also: 
//<font color="maroon"><b>lcd.line</b></font>, 
//<font color="maroon"><b>lcd.verline</b></font>, 
//<font color="maroon"><b>lcd.horline</b></font>, 
//<font color="maroon"><b>lcd.filledrectangle</b></font>, 
//<font color="maroon"><b>lcd.fill</b></font>.
//--------------------------------------------------------------------
Object.defineProperty(lcd, 'redbits', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD).</b><br><br>
//A 16-bit value packing two 8-bit parameters: number of "red" bits per pixel (high byte) and the position of the least significant red bit within the color word (low byte).
//<br><br>
//The value of this property depends on the currently selected controller/panel. This property is only relevant for color panels (
//<font color="maroon"><b>lcd.paneltype</b></font>= 
//<font color="olive"><b>1- PL_LCD_PANELTYPE_COLOR</b></font>).
//<br><br>
//Together with 
//<font color="maroon"><b>lcd.bluebits </b></font>and 
//<font color="maroon"><b>lcd.greenbits</b></font>, this property allows you to understand the composition of a color word used in 
//<font color="maroon"><b>lcd.setpixel</b></font>, 
//<font color="maroon"><b>lcd.forecolor</b></font>, and 
//<font color="maroon"><b>lcd.backcolor</b></font>.
//--------------------------------------------------------------------
Object.defineProperty(lcd, 'rotated', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0- NO (not rotated).</b><br><br>
//Specifies whether the image on the display panel is to be rotated 180 degrees: 
//<font color="olive"><b>0- NO </b></font>(not rotated), or 
//<font color="olive"><b>1- YES </b></font>(rotated 180 degrees).
//<br><br>
//Set this property according to the orientation of the display panel in your device.
//<br><br>
//This property can only be changed when the display is disabled (
//<font color="maroon"><b>lcd.enabled</b></font>= 
//<font color="olive"><b>0- NO</b></font>). 
//--------------------------------------------------------------------
lcd.setfont = function (offset) { };
//<b>METHOD. </b><br><br>
//Selects a font to use for printing text. Returns 
//<font color="olive"><b>0- OK </b></font>if the font was found and the data appears to be valid. Returns 
//<font color="olive"><b>1- NG </b></font>if there is no valid font data at specified offset.
//<br><br>
//<b>Offset </b>is the offset within the compiled binary of your application at which the font file is stored.
//<br><br>
//A valid font file must be selected before you can use the 
//<font color="maroon"><b>lcd.print</b></font>, 
//<font color="maroon"><b>lcd.printaligned</b></font>, or 
//<font color="maroon"><b>lcd.getprintwidth </b></font>methods.
//Naturally, the font file must be present in your project for this to work (see how to add a font file).
//To obtain correct offset, open the file using the romfile.open method, then read the offset of this file from the 
//<font color="maroon"><b>romfile.offset </b></font>R/O property.
//<br><br>
//When the font file is successfully selected, the 
//<font color="maroon"><b>lcd.fontheight </b></font>and 
//<font color="maroon"><b>lcd.fontpixelpacking </b></font>R/O properties will be updated to reflect actual font parameters.
//--------------------------------------------------------------------
lcd.setpixel = function (dt, x, y) { };
//<b>METHOD. </b><br><br>
//Directly writes pixel data <b>dt </b>for a single pixel at <b>x</b>, <b>y </b>coordinates.
//<br><br>
//Interpretation of the dt argument depends on the selected controller/panel. Only 
//<font color="maroon"><b>lcd.bitsperpixel </b></font> lower bits of this value will be relevant. All higher bits will be ignored.
//<br><br>
//For monochrome and grayscale controllers/panels (
//<font color="maroon"><b>lcd.paneltype</b></font>= 
//<font color="olive"><b>0- PL_LCD_PANELTYPE_GRAYSCALE</b></font>), the value of the dt argument sets the brightness of the pixel.
//For color panels/controllers (
//<font color="maroon"><b>lcd.paneltype</b></font>= 
//<font color="olive"><b>1- PL_LCD_PANELTYPE_COLOR</b></font>) the value is composed of three fields -- one for the red, green, and blue "channels".  Check 
//<font color="maroon"><b>lcd.redbits</b></font>, 
//<font color="maroon"><b>lcd.greenbits</b></font>, and 
//<font color="maroon"><b>lcd.bluebits </b></font>properties to see how the fields are combined into the dt word.
//<br><br>
//The display panel must be enabled (
//<font color="maroon"><b>lcd.enabled</b></font>= 
//<font color="olive"><b>1- YES</b></font>) for this method to work.
//--------------------------------------------------------------------
lcd.getpixel = function (x, y) { };
//<b>METHOD. </b><br><br>
//UNDOCUMENTED
//--------------------------------------------------------------------
//<b>PLATFORM CONSTANT.</b><br> Top, left.
//<b>PLATFORM CONSTANT.</b><br> Top, center.
//<b>PLATFORM CONSTANT.</b><br> Top, right.
//<b>PLATFORM CONSTANT.</b><br> Middle, left.
//<b>PLATFORM CONSTANT.</b><br> Middle, center.
//<b>PLATFORM CONSTANT.</b><br> Middle, right.
//<b>PLATFORM CONSTANT.</b><br> Bottom, left.
//<b>PLATFORM CONSTANT.</b><br> Bottom, center.
//<b>PLATFORM CONSTANT.</b><br> Bottom, right.
//--------------------------------------------------------------------
Object.defineProperty(lcd, 'textalignment', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0- PL_LCD_TEXT_ALIGNMENT_TOP_LEFT (top, left).</b><br><br>
//Specifies the alignment for text output produced by the 
//<font color="maroon"><b>lcd.printaligned </b></font>method. There are 9 alignment choices from "top, left" to "bottom, right". 
//<br><br>
//<font color="maroon"><b>Lcd.printaligned </b></font>fits the text within a specified rectangular area. 
//<font color="maroon"><b>lcd.textalignment </b></font>defines how the text will be aligned within this area.
//The property has no bearing on the output produced by 
//<font color="maroon"><b>lcd.print</b></font>.
//<br><br>
//See also: 
//<font color="maroon"><b>lcd.textorientation</b></font>, 
//<font color="maroon"><b>lcd.texthorizontalspacing</b></font>, 
//<font color="maroon"><b>lcd.textverticalspacing</b></font>.
//--------------------------------------------------------------------
Object.defineProperty(lcd, 'texthorizontalspacing', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (BYTE), DEFAULT VALUE= 1 (1 pixel).</b><br><br>
//Specifies the gap, in pixels, between characters of text output produced by the 
//<font color="maroon"><b>lcd.print </b></font>and 
//<font color="maroon"><b>lcd.printaligned </b></font>methods.
//<br><br>
//See also: 
//<font color="maroon"><b>lcd.textalignment</b></font>, 
//<font color="maroon"><b>lcd.textorientation</b></font>, 
//<font color="maroon"><b>lcd.textverticalspacing</b></font>.
//--------------------------------------------------------------------
//<b>PLATFORM CONSTANT.</b><br> At 0 degrees.
//<b>PLATFORM CONSTANT.</b><br> At 90 degrees.
//<b>PLATFORM CONSTANT.</b><br> At 180 degrees.
//<b>PLATFORM CONSTANT.</b><br> At 270 degrees.
Object.defineProperty(lcd, 'textorientation', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE= PL_LCD_TEXT_ORIENTATION_0 (at 0 degrees).</b><br><br>
//Specifies the print angle for text output produced by the 
//<font color="maroon"><b>lcd.print </b></font>and 
//<font color="maroon"><b>lcd.printaligned </b></font>methods.
//<br><br>
//See also: 
//<font color="maroon"><b>lcd.textalignment</b></font>, 
//<font color="maroon"><b>lcd.texthorizontalspacing</b></font>, 
//<font color="maroon"><b>lcd.textverticalspacing</b></font>.
//--------------------------------------------------------------------
Object.defineProperty(lcd, 'textverticalspacing', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (BYTE), DEFAULT VALUE= 1 (1 pixel).</b><br><br>
//Specifies the gap, in pixels, between the lines of text output produced by the 
//<font color="maroon"><b>lcd.printaligned </b></font>method.
//<br><br>
//The property has no bearing on the output produced by 
//<font color="maroon"><b>lcd.print</b></font>, because this method always creates a single-line output.
//<br><br>
//See also: 
//<font color="maroon"><b>lcd.textalignment</b></font>, 
//<font color="maroon"><b>lcd.textorientation</b></font>, 
//<font color="maroon"><b>lcd.texthorizontalspacing</b></font>.
//--------------------------------------------------------------------
lcd.unlock = function () { };
//<b>METHOD. </b><br><br>
//Unfreezes display output (on controllers/panels that support this feature).
//<br><br>
//When the display is locked (see 
//<font color="maroon"><b>lcd.lock</b></font>), you can make changes to the display data without showing these changes on the screen.
//You can then unlock the display (<font color="maroon"><b> lcd.unlock</b></font>) and
//show all the changes made at once. This usually greatly improves the display agility perception by the user.
//<br><br>
//Each time you execute this method on a previously locked display, the value of the 
//<font color="maroon"><b>lcd.lockcount </b></font>R/O property decreases by 1.  Once this value reaches 0, the display is unlocked and the user sees updated display data.  The 
//<font color="maroon"><b>lcd.lockcount </b></font>allows you to nest locks/unlocks.
//--------------------------------------------------------------------
lcd.verline = function (x, y1, y2) { };
//<b>METHOD. </b><br><br>
//Draws a vertical line.
//<br><br>
//<b>x</b> -- X coordinates of the first and second points. Value range is 0 to 
//<font color="maroon"><b>lcd.width</b></font>-1.
//<br>
//<b>y1</b> -- Y coordinate of the first point. Value range is 0 to 
//<font color="maroon"><b>lcd.height</b></font>-1.
//<br>
//<b>y2</b> -- Y coordinate of the second point. Value range is 0 to 
//<font color="maroon"><b>lcd.height</b></font>-1.
//<br><br>
//The line is drawn with the specified line widht (
//<font color="maroon"><b>lcd.linewidth</b></font>) and "pen" color (
//<font color="maroon"><b>lcd.forecolor</b></font>).
//Drawing horizontal (
//<font color="maroon"><b>lcd.horline</b></font>) or vertical lines is more efficient than drawing generic lines (
//<font color="maroon"><b>lcd.line</b></font>) and should be used whenever possible.
//<br><br>
//The display panel must be enabled (
//<font color="maroon"><b>lcd.enabled</b></font>= 
//<font color="olive"><b>1- YES</b></font>) for this method to work.
//<br><br>
//See also: 
//<font color="maroon"><b>lcd.rectangle</b></font>, 
//<font color="maroon"><b>lcd.filledrectangle</b></font>, 
//<font color="maroon"><b>lcd.fill</b></font>.
//--------------------------------------------------------------------
Object.defineProperty(lcd, 'width', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (WORD), DEFAULT VALUE= 0.</b><br><br>
//Sets the horizontal resolution of the display panel in pixels.
//<br><br>
//Set this property according to the characteristics of your display panel.
//The reason why this value is not set automatically when you select a certain controller is because the capability of the controller may exceed the actual resolution of the panel,
//i.e. only "part" of the controller may be utilized.
//<br><br>
//This property can only be changed when the display is disabled (
//<font color="maroon"><b>lcd.enabled</b></font>= 
//<font color="olive"><b>0- NO</b></font>). 
//<br><br>
//See also: 
//<font color="maroon"><b>lcd.height</b></font>.
//--------------------------------------------------------------------
//--------------------------------------------------------------------
//--------------------------------------------------------------------
//--------------------------------------------------------------------
//--------------------------------------------------------------------
Object.defineProperty(lcd, 'buffsize', {
    get() { return 0; },
    set() { }
});
//**************************************************************************************************
//		KP (keypad) object
//**************************************************************************************************
//Depending on the kp.mode property, the keypad object works with a "matrix" keypad of up to 64 keys (8 scan lines by 8 return lines) or
//"binary output" keypad of up to 255 keys that sends key codes through up to 8 return lines.
//--------------------------------------------------------------------
//<b>PLATFORM CONSTANT. The keypad is of matrix type. </b><br><br>
//<b>PLATFORM CONSTANT. The keypad is of binary output type. </b><br><br>
Object.defineProperty(kp, 'mode', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0- PL_KP_MODE_MATRIX (matrix type).</b><br><br>
//Specifies the type of the keypad attached to your TiOS device.
//<br><br>
//Matrix keypads (kp.mode= 0- PL_KP_MODE_MATRIX) are defined by a number of scan and return lines (see kp.scanlinesmapping and kp.returnlinesmapping).
//<br><br>
//Binary keypads (kp.mode= 1- PL_KP_MODE_BINARY) only need return lines and directly output the binary codes of keys.
//The kp.idlecode property must match the code sent by your binary keypad when no key is pressed.
//<br><br>
//This property can only be changed when the keypad is disabled (kp.enabled= 0- NO).
//--------------------------------------------------------------------
Object.defineProperty(kp, 'idlecode', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (BYTE), DEFAULT VALUE= 0.</b><br><br>
//Specifies the code that is expected to be present on the return lines of a binary keypad when no key is pressed.
//<br><br>
//This property is only relevant for binary keypads (kp.mode= 1- PL_KP_MODE_BINARY).
//<br><br>
//This property can only be changed when the keypad is disabled (kp.enabled= 0- NO).
//--------------------------------------------------------------------
Object.defineProperty(kp, 'autodisablecodes', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (STRING), DEFAULT VALUE= "".</b><br><br>
//Defines what key event + key code combinations disable the keypad (set kp.enabled= 0- NO).
//<br><br>
//This property should contain a comma-separated list of event codes and key codes, for example: "2,15,0,20".
//In this example, two event/code pairs are "2,15" and "0,20":
//<br>
//Event "2" is 2-PL_KP_EVENT_PRESSED;
//<br>
//Event "0" is 0-PL_KP_EVENT_LONGRELEASED;
//<br>
//"15" and "20" are key codes.
//<br><br>
//So, the keypad will be disabled when the key with code 15 is detected to be _RESSED,
//or the key with code 20 is detected to be _LONGRELEASED.
//<br><br>
//This property can only be changed when the keypad is disabled (kp.enabled= 0- NO).
//--------------------------------------------------------------------
Object.defineProperty(kp, 'enabled', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0- NO (disabled).</b><br><br>
//Enables or disables the keypad.
//<br><br>
//The keypad is only active when the kp. object is enabled (kp.enabled= 1- YES).
//<br><br>
//The keypad will be auto-disabled if an overflow is detected (see on_kp_overflow event), or if one of the conditions for automatic keypad disablement is met (see kp.autodisablecodes).
//<br><br>
//Every time the keypad is re-enabled, each key's state is set to 0- PL_KP_EVENT_LONGRELEASED, and the keypad event FIFO is cleared.
//<br><br>
//It is only possible to change the values of kp. object's properties when kp.enabled= 0- NO.
//--------------------------------------------------------------------
Object.defineProperty(kp, 'longpressdelay', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (BYTE), DEFAULT VALUE= 100 (1 sec).</b><br><br>
//Defines (in 10ms increments) the amount of time a key will have to remain pressed for the key state to transition from _PRESSED into _LONGPRESSED. Value range is 0-254.
//<br><br>
//A new keypad event with 3- PL_KP_EVENT_LONGPRESSED event code will be added to the keypad event FIFO once a key transitions into the _LONGPRESSED state.
//<br><br>
//This property can only be changed when the keypad is disabled (kp.enabled= 0- NO). Setting the property to 0 means that the key will never transition into the _LONGPRESSED state.
//--------------------------------------------------------------------
Object.defineProperty(kp, 'longreleasedelay', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (BYTE), DEFAULT VALUE= 100 (1 sec).</b><br><br>
//Defines (in 10ms increments) the amount of time a key will have to remain released for the key state to transition from _RELEASED into _LONGRELEASED state. Value range is 0-254.
//<br><br>
//A new keypad event with 0- PL_KP_EVENT_LONGRELEASED event code will be added to the keypad event FIFO once a key transitions into the _LONGRELEASED state.
//<br><br>
//This property can only be changed when the keypad is disabled (kp.enabled= 0- NO). Setting the property to 0 means that the key will never transition into the "_LONGRELEASED state.
//--------------------------------------------------------------------
//<b>PLATFORM CONSTANT.</b><br><br> The key has transitioned into the "longreleased" state.
//<b>PLATFORM CONSTANT.</b><br><br> The key has transitioned into the "released" state.
//<b>PLATFORM CONSTANT.</b><br><br> The key has transitioned into the "pressed" state.
//<b>PLATFORM CONSTANT.</b><br><br> The key has transitioned into the "longpressed" state.
//<b>PLATFORM CONSTANT.</b><br><br> Auto-repeat for the key.
//<b>PLATFORM CONSTANT.</b><br><br> The keypad appears to be jammed. Can only be generated when <font color="maroon"><b>kp.mode</b></font>='<font color="olive"><b> 1- PL_KP_MODE_BINARY</b></font>).
//<b>EVENT of the kp object. </b><br><br>
//When kp.genkpevent= 1- YES, this event is generated whenever a key transitions into a new state.
//<br><br>
//Pressing and releasing any key on the keypad can generate up to five different events.
//<br><br>
//This event can only be generated when the keypad is enabled (kp.enabled= 1- YES).
//<br><br>
//Another on_kp event is never generated until the previous one is processed (even though multiple keypad events may be waiting in the keypad event FIFO).
//--------------------------------------------------------------------
//<b>EVENT of the kp object. </b><br><br>
//Indicates that the keypad event FIFO has overflown and some key events may have been lost.
//<br><br>
//Once the FIFO overflows, the keypad is disabled (kp.enabled= 0- NO). You can re-enable the keypad by setting kp.enabled= 1- YES (this will also clear the FIFO).
//<br><br>
//Another on_kp_overflow event is never generated until the previous one is processed.
//--------------------------------------------------------------------
Object.defineProperty(kp, 'pressdelay', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (BYTE), DEFAULT VALUE= 3 (30 ms).</b><br><br>
//Defines (in 10ms increments) the amount of time a key will have to remain pressed for the key state to transition from _RELEASED into _PRESSED. Value range is 0-254.
//<br><br>
//A new keypad event with 2- PL_KP_EVENT_PRESSED event code will be added to the keypad event FIFO once a key transitions into the _PRESSED state.
//<br><br>
//This property can only be changed when the keypad is disabled (kp.enabled= 0- NO). Setting the property to 0 means that the key will never transition into the _PRESSED state.
//--------------------------------------------------------------------
Object.defineProperty(kp, 'releasedelay', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (BYTE), DEFAULT VALUE= 3 (30 ms).</b><br><br>
//Defines (in 10ms increments) the amount of time a key will have to remain released for the key state to transition from _PRESSED or _LONGPRESSED into _RELEASED. Value range is 0-254.
//<br><br>
//A new keypad event with 1- PL_KP_EVENT_RELEASED event code will be added to the keypad event FIFO once a key transitions into the _RELEASED state.
//<br><br>
//This property can only be changed when the keypad is disabled (kp.enabled= 0- NO). Setting the property to 0 means that the key will never transition into the _RELEASED state.
//--------------------------------------------------------------------
Object.defineProperty(kp, 'repeatdelay', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (BYTE), DEFAULT VALUE= 50 (0.5 sec.).</b><br><br>
//Defines (in 10ms increments) the time period at which the on_kp event with 4- PL_KP_EVENT_REPEATPRESSED event code will be generated once the key reaches the _LONGPRESSED state and remains pressed.
//Value range is 0-254.
//<br><br>
//A new keypad event with 4- PL_KP_EVENT_REPEATPRESSED event code will be added to the keypad event FIFO when a key (re-) transitions into the _REPEATPRESSED state.
//<br><br>
//This property can only be changed when the keypad is disabled (kp.enabled= 0- NO).
//Setting the property to 0 means that the key will never transition into the _REPEATPRESSED state.
//--------------------------------------------------------------------
Object.defineProperty(kp, 'lockupdelay', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (WORD), DEFAULT VALUE= 1000 (10sec).</b><br><br>
//Defines (in 10ms increments) the amount of time any key will have to stay pressed for the keypad to enter the "lockup" state. 
//<br><br>
//Lockup is not a key state, it is the state of the keypad as a whole. Once the lockup condition is detected the keypad is disabled (kp.enabled= 0- NO).
//<br><br>
//This property can only be changed when the keypad is disabled (kp.enabled= 0- NO). Setting the property to 0 means that the keypad will never enter the "lockup" state.
//--------------------------------------------------------------------
Object.defineProperty(kp, 'returnlinesmapping', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (STRING), DEFAULT VALUE= "".</b><br><br>
//Defines the list of up to 8 I/O lines that will serve as return lines of the keypad.
//<br><br>
//This property should contain a comma-separated list of I/O lines numbers, for example: "24, 26, 27". Line numbers correspond to those of the pl_io_num enum.
//The order in which you list the return lines does matter! 
//<br><br>
//On platforms with output buffer control, all intended return lines should be configured as inputs by your application (see io.num and io.enabled).
//<br><br>
//This property can only be changed when the keypad is disabled (kp.enabled= 0- NO).
//A keypad must have at least one return line to be able to function.
//<br><br>
//Return lines of the keypad should be separate from the scan lines (see kp.scanlinesmapping).
//--------------------------------------------------------------------
Object.defineProperty(kp, 'scanlinesmapping', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (STRING), DEFAULT VALUE= "".</b><br><br>
//Defines the list of up to 8 I/O lines that will serve as scan lines of the matrix keypad.
//<br><br>
//This property should contain a comma-separated list of I/O lines numbers, for example: "24, 26, 27". Line numbers correspond to those of the pl_io_num enum.
//The order in which you list the scan lines does matter! 
//<br><br>
//On platforms with output buffer control, all intended scan lines should be configured as outputs by your application (see io.num and io.enabled).
//<br><br>
//This property can only be changed when the keypad is disabled (kp.enabled= 0- NO).
//<br><br>
//Scan lines of the keypad should be separate from the return lines (see kp.returnlinesmapping).
//Scan lines are only required if you are working with a matrix keypad.
//--------------------------------------------------------------------
kp.getkey = function (key_event, key_code) { };
//<b>METHOD. </b><br><br> 
//When kp.genkpevent= 0- NO, calling this method attempts to fetch one keypad event from the keypad event FIFO.
//The method returns 0- OK if there was a keypad event waiting in the FIFO, or 1- NG if the FIFO was empty.
//<br><br>
//If the method returns 0- OK, the key state transition and the key code for the fetched event can be obtained through key_event and key_code byref arguments of the kp.getkey method.
//--------------------------------------------------------------------
Object.defineProperty(kp, 'genkpevent', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE= 1- YES (event will be generated).</b><br><br>
//If kp.genkpevent= 1- YES, then you will be receiving keypad events through the on_kp event.
//If kp.genkpevent= 0- NO, then you will need to use the kp.getkey method to poll for keypad events.
//--------------------------------------------------------------------
Object.defineProperty(kp, 'overflow', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0- NO (no overflow).</b><br><br>
//Informs whether the keypad is currently in the overflow state.
//<br><br>
//This is an alternative to using the on_kp_overflow event.
//--------------------------------------------------------------------
kp.clearbuffer = function () { };
//<b>METHOD. </b><br><br>
//Clears the keypad event FIFO.
//--------------------------------------------------------------------
//**************************************************************************************************
//       SSI (Synchronous Serial Interface) object
//**************************************************************************************************
//--------------------------------------------------------------------
//The ssi. object implements up to four serial synchronous interfaces (SSI) on the general-purpose I/O lines of your device.
//Examples of such interfaces are SPI, I2C, clock/data, and numerous variations on these interfaces.
//--------------------------------------------------------------------
Object.defineProperty(ssi, 'baudrate', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (BYTE), DEFAULT VALUE= 1 (the fastest clock rate possible). </b><br><br>
//For the currently selected SSI channel (see ssi.channel) sets the clock rate on the CLK line (1-255).
//<br><br>
//When PLL is enabled (sys.currentpll= 1- PL_ON) the clock period can be calculated as 0.8us + ssi.baudrate * 0.1126uS.
//With PLL disabled, the clock period will be 8 times longer.
//<br><br>
//This property can only be changed when ssi.enabled= 0- NO.
//<br><br>
//It is actually permissible to set the property to 0 -- this will be like setting it to 256 (slowest possible clock rate).
//<br><br>
//See also: ssi.direction, ssi.mode, ssi.zmode.
//--------------------------------------------------------------------
Object.defineProperty(ssi, 'channel', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (BYTE), DEFAULT VALUE= 0 (channel #0 selected). </b><br><br>
//Sets/returns the number of the currently selected SSI channel (channels are enumerated from 0).
//There are four channels available (0-3).
//<br><br>
//All other properties and methods of this object relate to the channel selected through this property.
//--------------------------------------------------------------------
Object.defineProperty(ssi, 'clkmap', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE= PL_IO_NULL (NULL line).</b><br><br>
//For the currently selected SSI channel (see ssi.channel) sets/returns the number of the general-purpose I/O line to serve as the clock (CLK) line of this channel.
//<br><br>
//This property can only be changed when ssi.enabled= 0- NO.
//<br><br>
//On devices with unidirectional I/O lines, the CLK line must be "manually" configured as output (see io.enabled= 1- YES).
//<br><br>
//See also: ssi.dimap, ssi.domap.
//--------------------------------------------------------------------
Object.defineProperty(ssi, 'dimap', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE= PL_IO_NULL (NULL line).</b><br><br>
//For the currently selected SSI channel (see ssi.channel) sets/returns the number of the general-purpose I/O line to serve as the data in (DI) line of this channel.
//<br><br>
//This property can only be changed when ssi.enabled= 0- NO.
//<br><br>
//On devices with unidirectional I/O lines, the DI line must be "manually" configured as input (see io.enabled= 0- NO).
//<br><br>
//See also: ssi.clkmap, ssi.domap.
//--------------------------------------------------------------------
//<b>PLATFORM CONSTANT. Data input/output least significant bit first.</b><br><br>.
//<b>PLATFORM CONSTANT. Data input/output most significant bit first.</b><br><br>.
Object.defineProperty(ssi, 'direction', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (BYTE), DEFAULT VALUE= 0- PL_SSI_DIRECTION_RIGHT. </b><br><br>
//For the currently selected SSI channel (see ssi.channel) sets/returns the direction of data input and output:
//PL_SSI_DIRECTION_RIGHT means "least significant bit first", PL_SSI_DIRECTION_LEFT -- "most significant bit first".
//<br><br>
//This property can only be changed when ssi.enabled= 0- NO.
//--------------------------------------------------------------------
Object.defineProperty(ssi, 'domap', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE= PL_IO_NULL (NULL line).</b><br><br>
//For the currently selected SSI channel (see ssi.channel) sets/returns the number of the general-purpose I/O line to serve as the data out (DO) line of this channel.
//<br><br>
//This property can only be changed when ssi.enabled= 0- NO.
//<br><br>
//On devices with unidirectional I/O lines, the DO line must be "manually" configured as output (see io.enabled= 1- YES).
//<br><br>
//See also: ssi.clkmap, ssi.dimap.
//--------------------------------------------------------------------
Object.defineProperty(ssi, 'enabled', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0- NO (disabled).</b><br><br>
//Enables/disables the currently selected SSI channel (see ssi.channel).
//<br><br>
//SSI channel's operating parameters (ssi.baudrate, ssi.mode, etc.) can only be changed when the channel is disabled.
//<br><br>
//You can only send and receive the data (ssi.value, ssi.str) when the channel is enabled.
//--------------------------------------------------------------------
//<b>PLATFORM CONSTANT.</b><br><br>.
//<b>PLATFORM CONSTANT.</b><br><br>.
//<b>PLATFORM CONSTANT.</b><br><br>.
//<b>PLATFORM CONSTANT.</b><br><br>.
Object.defineProperty(ssi, 'mode', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (BYTE), DEFAULT VALUE= 0- PL_SSI_MODE_0. </b><br><br>
//For the currently selected SSI channel (see ssi.channel) sets/returns the clock mode.
//<br>
//The mode corresponds to standard SPI modes 0-3:<br>
//Mode 0: CPOL=0, CPHA=0<br>
//Mode 1: CPOL=0, CPHA=1<br>
//Mode 2: CPOL=1, CPHA=0<br>
//Mode 3: CPOL=1, CPHA=1<br>
//<br><br>
//CPOL is "clock polarity", CPHA is "clock phase".
//<br><br>
//CPOL=0: clock line is LOW when idle:
//<br>
//  - CPHA=0: data bits are captured on the CLK's rising edge (LOW-to-HIGH transition) and data bits are propagated on the CLK's falling edge (HIGH-to-LOW transition).
//<br>
//  - CPHA=1: data bits are captured on the CLK's falling edge and data bits are propagated on the CLK's rising edge.
//<br><br>
//CPOL=1: clock line is HIGH when idle:
//<br>
//  - CPHA=0: data bits are captured on the CLK's falling edge and data bits are propagated on the CLK's rising edge.
//<br>
//  - CPHA=1: data bits are captured on the CLK's rising edge and data bits are propagated on the CLK's falling edge.
//<br><br>
//See also: ssi.baudrate, ssi.direction, ssi.zmode.
//--------------------------------------------------------------------
//<b>PLATFORM CONSTANT. 8 bits per data byte. Acknowledgement bits are not transmitted (or expected to be received).</b><br><br>.
//<b>PLATFORM CONSTANT. 9 bits per data byte. Acknowledgement bits are expected to be generated by the slave and their presence will be verified.
//The slave device should pull the DI line LOW on the 9th bit of the byte transmission.
//Data exchange will be aborted if the slave device fails to acknowledge any of the bytes. This doesn't apply to the last byte because the method execution will
//end after the transmission of this byte anyway.</b><br><br>.
//<b>PLATFORM CONSTANT. 9 bits per data byte. Acknowledgement bits are generated by this device and each byte will be acknowledged by pulling the DI line low on the 9th bit
//of the byte transmission.</b><br><br>.
//<b>PLATFORM CONSTANT. 9 bits per data byte. Acknowledgement bits are generated by this device and each byte <b>except the last </b>will be acknowledged by pulling the DI line low
//on the 9th bit of the byte transmission.
//on the 9th bit of the transmission.</b><br><br>.
ssi.str = function (txdata, ack_bit) { };
//<b>METHOD.</b><br><br>
//For the currently selected SSI channel (see ssi.channel) outputs a string of byte data to the slave device and simultaneously inputs the same amount of data from the slave device.
//<br><br>
//<b>Txdata </b>-- the string to send to the slave device.
//<br><br>
//<b>Ack_bit </b>-- defines how data bytes are transmitted and acknowledgements handled -- see pl_ssi_ack_modes for details.
//<br><br>
//The method will return a string of the same length as txdata or less if the transmission ended prematurely due to the acknowledgement error by the slave. Obviously, the error can only occur when ack_bit= PL_SSI_ACK_RX.
//In this mode, if the slave device fails to acknowledge any byte "in the middle", the transmission will terminate. The length of the returned string will indicate how many bytes were sent. 
//<br><br>
//This method can be invoked only when ssi.enabled= 1- YES.
//<br><br>
//See also: ssi.value.
//--------------------------------------------------------------------
ssi.value = function (txdata, len) { };
//<b>METHOD.</b><br><br>
//For the currently selected SSI channel (see ssi.channel) outputs a data word of up to 16 bits and simultaneously inputs a data word of the same length.
//<br><br>
//<b>Txdata </b>-- data to output to the slave device. The number of rightmost bits equal to the len argument will be sent.
//<br><br>
//<b>Len </b>-- Number of data bits to send to and receive from the slave device.
//<br><br>
//The method will return a 16-bit value containing the data received from the slave device, the number of bits received will be equal to the len argument,
//and these data bits will be right-aligned within the returned 16-bit word.
//<br><br>
//Data input/output direction (least significant bit first or most significant bit first) is defined by the ssi.direction property. 
//<br><br>
//This method can be invoked only when ssi.enabled= 1- YES.
//<br><br>
//See also: ssi.str.
//--------------------------------------------------------------------
//<b>PLATFORM CONSTANT. The DO line toggles normally (by setting the output buffer to LOW or HIGH).</b><br><br>.
//<b>PLATFORM CONSTANT. For HIGH state, the output buffer of the DO line is turned off, for LOW state, the output buffer is turned on and the line is set to LOW.</b><br><br>.
Object.defineProperty(ssi, 'zmode', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (BYTE), DEFAULT VALUE= 0- PL_SSI_ZMODE_ALWAYS_ENABLED. </b><br><br>
//For the currently selected SSI channel (see ssi.channel) sets/returns the mode of the data out (DO) line:
//<br>
//PL_SSI_ZMODE_ALWAYS_ENABLED-- the DO line toggles normally by setting the output buffer to LOW or HIGH,
//<br>
//PL_SSI_ZMODE_ENABLED_ON_ZERO-- for HIGH state, the output buffer of the DO line is turned off, for LOW state, the output buffer is turned on and the line is set to LOW.
//<br><br>
//This property is only useful on devices with unidirectional I/O lines and in case the DO and DI lines are joined together, as necessary for the I2C and similar interfaces.
//<br><br>
//This property can only be changed when ssi.enabled= 0- NO.
//<br><br>
//See also: ssi.baudrate, ssi.direction, ssi.mode.
//**************************************************************************************************
//       FD (flash disk) object
//**************************************************************************************************
//This is the flash disk (fd.) object, it allows you to save data in the flash memory of your device.
//<br><br>
//The fd. object can be used to work with the flash memory in two different ways. You can
//(1) read and write individual sectors of the flash memory directly, or
//(2) create a formatted disk that stores files.
//--------------------------------------------------------------------
//<b>PLATFORM CONSTANT. </b><br><br>Completed successfully.
//<b>PLATFORM CONSTANT. </b><br><br>Physical flash memory failure (fatal: disk dismounted, must be reformatted).
//<b>PLATFORM CONSTANT. </b><br><br>Checksum error has been detected in one of the disk sectors (fatal: disk dismounted, must be reformatted).
//<b>PLATFORM CONSTANT. </b><br><br>Disk formatting error has been detected (fatal: disk dismounted, must be reformatted).
//<b>PLATFORM CONSTANT. </b><br><br>Invalid argument have been provided for the invoked method.
//<b>PLATFORM CONSTANT. </b><br><br>File with this name already exists.
//<b>PLATFORM CONSTANT. </b><br><br>Maximum number of files that can be stored on the disk has been reached, new file cannot be created.
//<b>PLATFORM CONSTANT. </b><br><br>The disk is full, new data cannot be added.
//<b>PLATFORM CONSTANT. </b><br><br>The disk is not mounted.
//<b>PLATFORM CONSTANT. </b><br><br>File not found.
//<b>PLATFORM CONSTANT. </b><br><br>No file is currently opened "on" the current fd.filenum.
//<b>PLATFORM CONSTANT. </b><br><br>This file is already opened "on" some other file number.
//<b>PLATFORM CONSTANT. </b><br><br>Disk transaction has already been started (and cannot be restarted).
//<b>PLATFORM CONSTANT. </b><br><br>Disk transaction hasn't been started yet.
//<b>PLATFORM CONSTANT. </b><br><br>Too many disk sectors have been modified in the cause of the current transaction (fatal: disk dismounted).
//<b>PLATFORM CONSTANT. </b><br><br>The disk wasn't formatted to support transactions (use fd.formatj with maxjournalsectors>1 to enable transactions).
//<b>PLATFORM CONSTANT. </b><br><br>Flash IC wasn't detected during boot, fd. object cannot operate normally.
//--------------------------------------------------------------------
Object.defineProperty(fd, 'availableflashspace', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD).</b><br><br>
//Returns the total number of sectors available to store application's data.
//<br><br>
//The value depends on the flash capacity and the flash memory arrangement of your device.
//<br><br>
//On devices with shared flash memory, this is the amount of memory that is not occupied by the currently loaded firmware/application.
//On devices with dedicated flash memory, this is the size of the second flash IC that stores fd. object's data.
//--------------------------------------------------------------------
Object.defineProperty(fd, 'buffernum', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (BYTE), DEFAULT VALUE= 0 (RAM buffer #0 selected).</b><br><br>
//Sets/returns the number of the RAM buffer that will be used for direct sector access.
//Possible values are 0 or 1.
//<br><br>
//All file-based operations of the flash disk also load data into the RAM buffers.
//Switch to the RAM buffer #0 <i>each time </i>before performing direct sector access with this or other related methods --
//this will guarantee that you won't corrupt the files and/or the file system and cause disk dismounting (fd.ready becoming 0- NO).
//<br><br>
//<b>See also: </b>
//fd.getbuffer,
//fd.setbuffer,
//fd.getsector,
//fd.setsector,
//fd.checksum,
//fd.copyfirmware,
//fd.copyfirmwarelzo
//--------------------------------------------------------------------
Object.defineProperty(fd, 'capacity', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD).</b><br><br>
//Returns the capacity, in sectors, of the currently existing flash disk.
//<br><br>
//The disk must be mounted (see fd.mount) for this property to return a meaningful value.
//<br><br>
//<b>See also: </b>
//fd.numservicesectors, fd.totalsize, fd.getfreespace, fd.maxstoredfiles, fd.getnumfiles
//--------------------------------------------------------------------
//PLATFORM CONSTANT. Verify the checksum.
//PLATFORM CONSTANT. Calculate the checksum.
fd.checksum = function (mode, csum) { };
//<b>METHOD. </b><br><br>
//Calculates and writes into the RAM buffer, or verifies the checksum for the data in the currently selected RAM buffer of the flash memory
//(selection is made through the fd.buffernum property).
//<br><br>
//<b>Mode </b>--
//<br>
//0- PL_FD_CSUM_MODE_VERIFY: verify the checksum.
//<br>
//1- PL_FD_CSUM_MODE_CALCULATE: calculate the checksum.
//<br><br>
//<b>Csum </b>-- After the checksum calculation, indirectly returns calculated value.
//<br><br>
//<b>Returns </b>--
//<br>
//0- OK: Completed successfully.
//<br>
//1- NG : The checksum was found to be invalid.
//<br>
//Also returns the calculation result indirectly, through the csum argument.
//<br><br>
//The checksum is calculated on bytes 0-263 of the selected RAM buffer and is stored at bytes 264 and 265 of the buffer.
//<br><br>
//<b>See also: </b>
//fd.buffernum,
//fd.getbuffer,
//fd.setbuffer,
//fd.getsector,
//fd.setsector,
//fd.copyfirmware,
//fd.copyfirmwarelzo
//--------------------------------------------------------------------
fd.close = function () { };
//<b>METHOD. </b><br><br>
//Closes the file opened "on" a currently selected file number (selection is made through fd.filenum).
//<br><br>
//Invoking the method also does the job performed by the fd.flush method.
//<br><br>
//Attempting to invoke this method "on" the file number that did not have any opened file associated with it generates no error. 
//--------------------------------------------------------------------
fd.copyfirmware = function (numsectors) { };
//<b>METHOD.</b><br><br>
//Copies the specified number of sectors (starting from the logical sector 0) from the data area into the TiOS/application area of the flash memory, then reboots the device to make it run new TiOS/application.
//<br><br>
//The data must start with TiOS firmware, optionally followed by the compiled Tibbo BASIC/C application binary.
//The numsectors argument must be specified to cover at least the size of the TiOS firmware. Specifying fewer sectors than that will abort the execution of this method.
//<br><br>
//<b>BE VERY CAREFUL! </b>Using the fd.copyfirmware on incorrect data will "incapacitate" your device and further remote upgrades will become impossible.</b>
//<br><br>
//<b>See also: </b>
//fd.copyfirmwarelzo,
//fd.copyfirmwarefromfile
//fd.copyfirmwarefromfilelzo
//--------------------------------------------------------------------
fd.copyfirmwarefromfile = function () { };
//<b>METHOD.</b><br><br>
//Copies the data from an opened and currently selected file of the flash disk (selection is made through fd.filenum) into the TiOS/application area of the flash memory,
//then reboots the device to make it run new TiOS/application.
//<br><br>
//The file is expected to start with TiOS firmware, optionally followed by a compiled Tibbo BASIC/C application binary.
//If the file is smaller than the size of TiOS firmware for this platform, the execution will be aborted.
//<br><br>
//<b>BE VERY CAREFUL! </b>Using the fd.copyfirmwarefromfile on incorrect data will "incapacitate" your device and further remote upgrades will become impossible.
//<br><br>
//<b>See also: </b>
//fd.copyfirmware
//fd.copyfirmwarelzo,
//fd.copyfirmwarefromfilelzo
//--------------------------------------------------------------------
//ARM
//Keytroller
//EM2000, TPP2(G2), TPP3(G2), other ARM platforms
fd.copyfirmwarelzo = function (app_present) { };
//<b>METHOD.</b><br><br>
//Assumes that there is a block of data containing the TiOS firmware, optionally followed by an LZO-compressed application binary stored beginning from the logical sector 0 of the flash memory.
//Copies TiOS firmware into the TiOS area of the flash. If the app_present argument is not zero, decompresses the application binary and copies it into the application area of the flash.
//After that, reboots the device to make it run new TiOS firmware (and application).
//<br><br>
//The application portion (compiled Tibbo BASIC/C application binary) is optional.
//<br><br>
//<b>BE VERY CAREFUL! </b>Using fd.copyfirmwarelzo on incorrect data will "incapacitate" your device and further remote upgrades will become impossible.
//<br><br>
//<b>See also: </b>
//fd.copyfirmware
//fd.copyfirmwarefromfile
//T1000
//--------------------------------------------------------------------
fd.copyfirmwarefromfilelzo = function () { };
//<b>METHOD.</b><br><br>
//Copies the data from an opened and currently selected file of the flash disk (selection is made through fd.filenum) into the TiOS/application area of the flash memory.
//The optional application binary portion of the file is expected to be LZO-compressed. After that, reboots the device to make it run new TiOS/application.
//<br><br>
//The file is expected to start with TiOS firmware, optionally followed by an LZO-compressed compiled Tibbo BASIC/C application binary.
//If the file is smaller than the size of TiOS firmware for this platform, the execution will be aborted.
//<br><br>
//<b>BE VERY CAREFUL! </b>Using fd.copyfirmwarefromfilelzo on incorrect data will "incapacitate" your device and further remote upgrades will become impossible.
//<br><br>
//fd.copyfirmware
//fd.copyfirmwarelzo,
//fd.copyfirmwarefromfile
//--------------------------------------------------------------------
fd.cutfromtop = function (numsectors) { };
//<b>METHOD. </b><br><br>
//Removed  a specified number of sectors from the beginning of a file opened "on" a currently selected file number (selection is made through fd.filenum). 
//<br><br>
//<b>Numsectors </b>-- Number of sectors to remove from the beginning of the file. Supplied value will be corrected downwards if exceeded the total number of sectors allocated to this file.
//<br><br>
//As a result of this method invocation, the pointer will be set to 0 if the file becomes empty, or 1 if the file still has some data in it.
//<br><br>
//<b>See also: </b> 
//fd.setfilesize 
//--------------------------------------------------------------------
fd.create = function (name_attr) { };
//<b>METHOD. </b><br><br>
//Creates a new file with the specified name and attributes.
//<br><br>
//<b>Name_attr </b>-- A string (1-56 characters),  must contain a file name and, optionally, attributes separated from the file name by a space. File names are case-sensitive.
//<br><br>
//Any character except space can be used in file names. This includes "/" and "\". This allows "subdirectory emulation".
//<br><br>
//When the file is created, one data sector is allocated to this file immediately.
//<br><br>
//<b>See also: </b> 
//fd.rename, fd.delete, fd.getnumfiles, fd.maxstoredfiles
//--------------------------------------------------------------------
fd.delete = function (name) { };
//<b>METHOD. </b><br><br>
//Deletes a file with the specified file name from the flash disk.
//<br><br>
//<b>Name </b>-- A string (1-56 characters) with the file name. All characters after the first space encountered (excluding leading spaces) will be ignored. File names are case-sensitive.
//<br><br>
//<b>See also: </b> 
//fd.create, fd.rename, fd.getnumfiles, fd.maxstoredfiles
//--------------------------------------------------------------------
Object.defineProperty(fd, 'filenum', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (BYTE), DEFAULT VALUE= 0 (file #0 selected).</b><br><br>
//Sets/returns the number of the currently selected file.
//<br><br>
//Several files can be opened (see fd.open) at the same time. Each file is said to be opened "on" a certain file number (the value of this property at the time of the file opening).
//<br><br>
//Although the file is opened by referring to its name, many other operations, such as fd.setdata or fd.close refer to the file number.
//--------------------------------------------------------------------
Object.defineProperty(fd, 'fileopened', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0- NO (no file is currently opened on this file number).</b><br><br>
//Reports if any file is currently opened "on" the selected file number (selection is made through fd.filenum.
//<br><br>
//Use fd.open to open files.
//<br><br>
//<b>See also: </b>
//fd.maxopenedfiles 
//--------------------------------------------------------------------
Object.defineProperty(fd, 'filesize', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (DWORD).</b><br><br>
//Returns the size, in bytes, of the file opened "on" the currently selected file number (selection is made through fd.filenum). Returns zero if no file is currently opened.
//<br><br>
//<b>See also: </b>
//fd.getdata, fd.setdata, fd.pointer, fd.setpointer
//--------------------------------------------------------------------
//PLATFORM CONSTANT. Find data that is equal to the substr.
//PLATFORM CONSTANT. Find data that is not equal to the substr.
//PLATFORM CONSTANT. Find data with value greater than the value of the substr.
//PLATFORM CONSTANT. Find data with value greater than or equal to the value of the substr.
//PLATFORM CONSTANT. Find data with value less than the value of the substr.
//PLATFORM CONSTANT. Find data with value less than or equal to the value of the substr.
fd.find = function (frompos, substr, instance, dir, incr, mode) { };
//<b>METHOD. </b><br><br>
//Finds the Nth instance of data satisfying selected criteria in a file opened "on" a currently selected file number (selection is made through fd.filenum).
//<br><br>
//Returns a position (counting from one) at which the target data instance was discovered, or 0 if the target instance was not found.
//<br><br>
//<b>Frompos </b>-- Starting position in a file from which the search will be conducted. File positions are counted from 1. Will be corrected automatically if out of range.
//<br><br>
//<b>Substr </b>-- The string to search for.
//<br><br>
//<b>Instance </b>-- Instance (occurrence) number to find.
//<br><br>
//<b>Dir </b>-- Search direction (forward or back)
//<br><br>
//<b>Incr </b>-- Search position increment (or decrement for BACK searches).
//<br><br>
//<b>Mode </b>-- Search mode (equal, not equal, etc.).
//--------------------------------------------------------------------
fd.flush = function () { };
//<b>METHOD. </b><br><br>
//Saves back to the flash memory ("flushes") the changes made to the most recently edited file.
//<br><br>
//When any data sector of the flash disk is being altered, this is done through a RAM buffer. To improve efficiency and reduce sector wear, the data from the RAM buffer is written back to the flash
//memory only when it becomes necessary to load the RAM buffer with the contents of another sector.
//<br><br>
//When the file is closed (see fd.close), RAM buffer "flushing" is done automatically.
//However, if changes are made to any file and then no disk activity is performed, the buffer may keep the data in the RAM buffer indefinitely.
//These changes will be lost if your device reboots. To prevent this, use fd.flush. 
//--------------------------------------------------------------------
fd.format = function (totalsize, maxstoredfiles) { };
//<b>METHOD. </b><br><br>
//Formats the flash memory to create a flash disk; no transaction journal sectors will be allocated.
//Use fd.formatj (recommended) to create the disk that will support transaction.
//<br><br>
//<b>Totalsize </b>-- Desired number of sectors occupied by the disk in flash memory. Cannot exceed available space (fd.availableflashspace).
//<br><br>
//<b>Maxstoredfiles </b>-- Desired maximum number of files that the disk will allow to create. Cannot exceed 64.
//<br><br>
//After formatting the disk will be in the dismounted state and will need to be mounted (see fd.mount) before any disk-related activity can be successfully performed.
//<b>See also: </b>
//fd.formatj,
//fd.mount,
//fd.ready
//--------------------------------------------------------------------
fd.formatj = function (totalsize, maxstoredfiles, maxjournalsectors) { };
//<b>METHOD. </b><br><br>
//Formats the flash memory to create a flash disk.
//<br><br>
//<b>Totalsize </b>-- Desired number of sectors occupied by the disk in flash memory. Cannot exceed available space (fd.availableflashspace).
//<br><br>
//<b>Maxstoredfiles </b>-- Desired maximum number of files that the disk will allow to create. Cannot exceed 64.
//<br><br>
//<b>Maxjournalsectors </b>-- Number of sectors to allocate for the transaction journal (suggested size: 50-100, definitely not less than 17). Setting to 0 or 1 disables disk transactions completely.
//<br><br>
//After formatting the disk will be in the dismounted state and will need to be mounted (see fd.mount) before any disk-related activity can be successfully performed.
//<br><br>
//<b>See also: </b>
//fd.mount,
//fd.ready
//--------------------------------------------------------------------
fd.getattributes = function (name) {
    if (fd.files[name] === undefined) {
        return '';
    }
    return fd.files[name];
};
//<b>METHOD. </b><br><br>
//Returns the attributes string for a file with the specified file name. Affects the state of fd.laststatus.
//<br><br>
//<b>Name </b>-- A string (1-56 characters) with the file name. All characters after the first space encountered (excluding leading spaces) will be ignored. File names are case-sensitive.
//<br><br>
//File attributes can be set with fd.create or fd.setattributes methods.
//--------------------------------------------------------------------
fd.getbuffer = function (offset, len) { };
//<b>METHOD. </b><br><br>
//Reads the specified number of bytes from the currently selected RAM buffer of the flash memory
//(selection is made through the fd.buffernum property). 
//<br><br>
//<b>Offset </b>-- Starting offset in the buffer. Possible value range is 0-263 (the buffer stores 264 bytes of data, offset is counted from 0).
//<br><br>
//<b>Len </b>-- Number of bytes to read. The length of returned data will depend on one of three factors, whichever is smaller:
//len argument, amount of data still available in the buffer counting from the offset position, and the capacity of receiving string variable.
//<br><br>
//<b>Returns </b>-- The string with the data from the buffer.
//<br><br>
//<b>See also: </b>
//fd.buffernum,
//fd.setbuffer,
//fd.getsector,
//fd.setsector,
//fd.checksum,
//fd.copyfirmware
//--------------------------------------------------------------------
fd.getdata = function (maxinplen) { };
//<b>METHOD. </b><br><br>
//Reads a specified number of bytes from the file opened "on" a currently selected file number (selection is made through fd.filenum). The data is read starting at the fd.pointer position.
//<br><br>
//<b>Maxinplen </b>-- Maximum number of bytes to read from the file. The length of returned data will depend on one of three factors, whichever is smaller:
//maxinplen argument, amount of data still available in the file counting from the current pointer position, and the capacity of receiving string variable.
//<br><br>
//As a result of this method invocation, the pointer will be advanced forward by the number of bytes actually read from the file.
//<br><br>
//<b>See also: </b> 
//fd.setdata, fd.setpointer, fd.filesize
//--------------------------------------------------------------------
fd.getfreespace = function () { };
//<b>METHOD. </b><br><br>
//Returns the total number of free data sectors available on the flash disk. Affects the state of the fd.laststatus.
//<br><br>
//The disk must be mounted (see fd.mount) for this property to return a meaningful value.
//<br><br>
//<b>See also: </b>
//fd.capacity, fd.numservicesectors, fd.totalsize, fd.maxstoredfiles, fd.getnumfiles
//--------------------------------------------------------------------
fd.getnextdirmember = function () { };
//<b>METHOD. </b><br><br>
//Returns the next filename (if any) found in the disk directory. An empty string will be returned if no more files are found.
//Affects the state of fd.laststatus.
//<br><br>
//Each time you invoke this method, internal directory "pointer" is incremented by one.
//<br><br>
//To obtain the list of disk files, use fd.resetdirpointer first, then invoke fd.getnextdirmember for the fd.getnumfiles number of times, or until the empty string is returned.
//--------------------------------------------------------------------
fd.getnumfiles = function () { };
//<b>METHOD. </b><br><br>
//Returns the total number of files currently stored on the disk. Affects the state of the fd.laststatus.
//<br><br>
//The disk must be mounted (see fd.mount) for this property to return a meaningful value.
//<br><br>
//<b>See also: </b>
//fd.capacity, fd.numservicesectors, fd.totalsize, fd.getfreespace, fd.maxstoredfiles
//--------------------------------------------------------------------
fd.getsector = function (num) { };
//<b>METHOD. </b><br><br>
//Reads the entire 264 bytes from the specified sector into the currently selected RAM buffer of the flash memory (selection is made through the fd.buffernum property).
//<br><br>
//<b>Num </b>-- Logical number of the sector to read from (logical numbers are in reverse: reading from the logical sector 0 actually means reading from the last physical sector of the flash IC).
//<br><br>
//All file-based operations of the flash disk also load data into the RAM buffers.
//Switch to the RAM buffer #0 <i>each time </i>before performing direct sector access with this or other related methods --
//this will guarantee that you won't corrupt the files and/or the file system and cause disk dismounting (fd.ready becoming 0- NO).
//<br><br>
//This method always accesses the actual specified target sector and not its cached copy even if the disk transaction is in progress
//(fd.transactionstarted= 1- YES) and the target sector has been cached already.
//<br><br>
//<b>See also: </b>
//fd.buffernum,
//fd.getbuffer,
//fd.setbuffer,
//fd.setsector,
//fd.checksum,
//fd.copyfirmware
//--------------------------------------------------------------------
Object.defineProperty(fd, 'laststatus', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0- PL_FD_STATUS_OK (completed successfully).</b><br><br>
//Returns the execution result for the most recent disk-related method execution. See pl_fd_status_codes enum for the list of all possible status codes.
//<br><br>
//Some methods, such as fd.create, return execution status directly. For those, the fd.laststatus will contain the same status as the one directly returned.
//<br><br>
//Other methods return some other data. For example, fd.getdata returns the data requested (or an empty string if something went wrong).
//The execution result for such methods can only be verified through this R/O property.
//<br><br>
//Note that some errors are fatal and the disk is dismounted (fd.ready is set to 0- NO) immediately upon the detection of any such fatal error.
//<br><br>
//--------------------------------------------------------------------
Object.defineProperty(fd, 'maxopenedfiles', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (BYTE).</b><br><br>
//Returns the total number of files that can be simultaneously opened by your application.
//<br><br>
//The value of this property depends on the hardware (selected platform) and has nothing to do with the formatting of your flash disk.
//--------------------------------------------------------------------
Object.defineProperty(fd, 'maxstoredfiles', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (BYTE).</b><br><br>
//Returns the total number of files that can be simultaneously stored on the currently existing flash disk.
//<br><br>
//This number cannot be changed unless the disk is reformatted (see fd.formatj).
//<br><br>
//The disk must be mounted (see  fd.mount) for this property to return a meaningful value.
//<br><br>
//<b>See also: </b>
//fd.capacity, fd.numservicesectors, fd.totalsize, fd.getfreespace, fd.getnumfiles
//--------------------------------------------------------------------
fd.mount = function () { };
//<b>METHOD. </b><br><br>
//Mounts (prepares for use) the flash disk already existing in the flash memory. 
//<br><br>
//The flash disk will not be accessible unless it is mounted using this method.
//The disk can only be mounted after the flash memory has been successfully formatted using the fd.formatj method.
//The disk has to be mounted after every reboot of your device.
//After the disk is mounted successfully, the fd.ready R/O property will read 1- YES. 
//<br><br>
//There is no way to explicitly dismount the disk, nor it is necessary.
//The disk will be dismounted automatically if any fatal condition is detected.
//<br><br>
//This method also finishes the "transaction commit job" if it was started with the fd.transactioncommit method and wasn't completed properly due to the power failure or some other reason.
//--------------------------------------------------------------------
Object.defineProperty(fd, 'numservicesectors', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (BYTE).</b><br><br>
//Returns the total number of sectors occupied by the "housekeeping" data of the currently existing flash disk.
//<br><br>
//The disk must be mounted (see fd.mount) for this property to return a meaningful value.
//<br><br>
//<b>See also: </b>
//fd.capacity, fd.totalsize, fd.getfreespace, fd.maxstoredfiles, fd.getnumfiles
//--------------------------------------------------------------------
fd.open = function (name) { };
//<b>METHOD. </b><br><br>
//Opens a file with a specified name "on" a currently selected file number (selection is made through fd.filenum).
//<br><br>
//<b>Name </b>-- A string (1-56 characters) with the file name. All characters after the first space encountered (excluding leading spaces) will be ignored. File names are case-sensitive.
//<br><br>
//You may reopen the same or another file "on" the same file number, but this can lead to the loss of (some) changes made to the previously opened file.
//<br><br>
//Always close (fd.close) the previously opened file first, or use fd.flush to save the most recent changes back to the disk.
//<br><br>
//You cannot open the same file "on" more than one file number.
//<br><br>
//<b>See also: </b>
//fd.fileopened, fd.maxopenedfiles
//--------------------------------------------------------------------
Object.defineProperty(fd, 'pointer', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (DWORD).</b><br><br>
//Returns the pointer position for the file opened "on" the currently selected file number (selection is made through fd.filenum). Returns zero if no file is currently opened or the file is empty.
//<br><br>
//For the files of 0 size (see fd.filesize), the pointer will always be at 0. If the file has a non-zero size, the pointer will be between 1 and fd.filesize+1.
//The first byte of the file is at position 1, the last one -- at position equal to fd.filesize. Fd.filesize+1 is the position at which new data can be appended to the file
//(except for empty files where the pointer will be at 0 until you add some data).
//<br><br>
//Move the pointer with fd.setpointer. Fd.getdata and fd.setdata also move the pointer by the amount of bytes read or written.
//Reducing the file size with fd.setfilesize or fd.cutfromtop may affect the pointer position.
//--------------------------------------------------------------------
Object.defineProperty(fd, 'ready', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0- NO (the disk is not mounted and is not ready for use).</b><br><br>
//Informs whether the flash disk is mounted and ready for use.
//<br><br>
//Use the fd.mount method to mount the disk.
//<br><br>
//<b>See also: </b> 
//fd.formatj
//--------------------------------------------------------------------
fd.rename = function (old_name, new_name) { };
//<b>METHOD. </b><br><br>
//Renames a file specified by its name. 
//<br><br>
//<b>Old_name </b>-- A string (1-56 characters) with the name of the file to be renamed. All characters after the first space encountered (excluding leading spaces) will be ignored.
//File names are case-sensitive.
//<br><br>
//<b>New_name </b>-- A string (1-56 characters) with the new name for the file. All characters after the first space encountered (excluding leading spaces) will be ignored.
//<br><br>
//Renaming the file preserves file attributes (see fd.getattributes, fd.setattributes).
//<br><br>
//<b>See also: </b>
//fd.create, fd.delete, fd.getnumfiles, fd.maxstoredfiles
//--------------------------------------------------------------------
fd.resetdirpointer = function () { };
//<b>METHOD. </b><br><br>
//Resets the directory pointer to zero.
//<br><br>
//Use this method before repeatedly invoking fd.getnextdirmember to obtain the list of files currently stored on the disk.
//<br><br>
//<b>See also: </b>
//fd.getnumfiles
//--------------------------------------------------------------------
Object.defineProperty(fd, 'sector', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD).</b><br><br>
//Returns the physical sector number corresponding to the current position of the file pointer position (see fd.pointer).
//<br><br>
//Because the sectors belonging to a given file may be scattered around the flash disk, there is no simple way to figure out the number of the physical sector
//corresponding to the current file pointer position (see fd.pointer).
//<br><br>
//This property exists purely for informational purposes. There is no real need for you to know where the fd. object stores your data.
//--------------------------------------------------------------------
fd.setattributes = function (name, attr) {
    fd.files[name] = attr;
};
//<b>METHOD. </b><br><br>
//Sets the attributes string for a file with the specified file name.
//<br><br>
//<b>Name </b>-- A string (1-56 characters) with the file name. All characters after the first space encountered (excluding leading spaces) will be ignored. File names are case-sensitive.
//<br><br>
//<b>Attr </b>-- A string with attributes to be set. Attributes length cannot exceed 56-length_of_the_file_name-1.
//This "-1" accounts for the space character that separates the file name from the attributes.
//<br><br>
//<b>See also: </b>
//fd.getattributes, fd.create
//--------------------------------------------------------------------
fd.setbuffer = function (data, offset) { };
//<b>METHOD. </b><br><br>
//Writes a specified number of bytes into the currently selected RAM buffer of the flash memory (selection is made through the fd.buffernum property). 
//<br><br>
//<b>Data </b>-- A string with the data to be written to the buffer.
//<br><br>
//<b>Offset </b>-- Starting offset in the buffer. Possible value range is 0-263 (the buffer stores 264 bytes of data, offset is counted from 0).
//<br><br>
//<b>Returns </b>-- Actual number of bytes written.
//<br><br>
//The length of data actually written into the buffer may be limited if all supplied data can't fit between the offset position in the buffer and the end of the buffer.
//<br><br>
//All file-based operations of the flash disk also load data into the RAM buffers.
//Switch to the RAM buffer #0 <i>each time </i>before performing direct sector access with this or other related methods --
//this will guarantee that you won't corrupt the files and/or the file system and cause disk dismounting (fd.ready becoming 0- NO).
//<br><br>
//<b>See also: </b>
//fd.buffernum,
//fd.getbuffer,
//fd.getsector,
//fd.setsector,
//fd.checksum,
//fd.copyfirmware
//--------------------------------------------------------------------
fd.setdata = function (data) { };
//<b>METHOD. </b><br><br>
//Writes the data string to a file opened "on" a currently selected file number (selection is made through fd.filenum). The data is written starting at the fd.pointer position.
//<br><br>
//<b>Data </b>-- A string containing the data to be written to the file. If the disk becomes full, then no data will be written (and not just the portion that could not fit).
//<br><br>
//As a result of this method invocation, the pointer will be advanced forward by the number of bytes written to the file.
//<br><br>
//If the pointer wasn't at the end of the file (fd.filesize+1 position) then some of the existing file data will be partially overwritten.
//If the pointer moves past the current file size then the file size will be increased automatically.
//<br><br>
//<b>See also: </b> 
//fd.getdata, fd.setpointer
//--------------------------------------------------------------------
fd.setfilesize = function (newsize) { };
//<b>METHOD. </b><br><br>
//Sets (reduces) the file size of a file opened "on" a currently selected file number (selection is made through fd.filenum.
//<br><br>
//<b>Newsize </b>-- Desired new file size in bytes. Supplied value will be corrected downwards if exceeded previous file size.
//<br><br>
//As a result of this method invocation, the pointer position may be corrected downwards. If the file becomes empty, the pointer will be set to zero.
//If the file still has some data in it, and the pointer exceeds new fd.filesize+1, then pointer will be set to fd.filesize+1. 
//<br><br>
//<b>See also: </b> 
//fd.cutfromtop
//--------------------------------------------------------------------
fd.setpointer = function (pos) { };
//<b>METHOD. </b><br><br>
//Sets the new pointer position for a file opened "on" a currently selected file number (selection is made through fd.filenum). 
//<br><br>
//For the files of 0 size (see fd.filesize), the pointer will always be at 0. If the file has a non-zero size, the pointer will be between 1 and fd.filesize+1.
//The first byte of the file is at position 1, the last one -- at position equal to fd.filesize. Fd.filesize+1 is the position at which new data can be appended to the file
//(except for empty files where the pointer will be at 0 until you add some data).
//<br><br>
//Fd.getdata and fd.setdata also move the pointer by the amount of bytes read or written.
//Reducing the file size with fd.setfilesize or fd.cutfromtop may affect the pointer position.
//<br><br>
//<b>See also: </b>
//fd.pointer
//--------------------------------------------------------------------
fd.setsector = function (num) { };
//<b>METHOD. </b><br><br>
//Writes the entire 264 bytes of the specified sector with the data from the currently selected RAM buffer of the flash memory
//(selection is made through the fd.buffernum property). 
//<br><br>
//<b>Num </b>-- Logical number of the sector to write to (logical numbers are in reverse:
//writing to the logical sector 0 actually means writing to the last physical sector of the flash IC).
//Acceptable range is 0 - fd.availableflashspace-1. 
//<br><br>
//The data area of the flash memory may house a formatted flash disk.
//Writing to the sector that belongs to the flash disk when the disk is mounted will automatically dismount the disk (set fd.ready= 0- NO)
//and may render the disk unusable.
//<br><br>
//This method always accesses the specified target sector and not its cached copy even if the disk transaction is in progress
//(fd.transactionstarted= 1- YES) and the target sector has been cached already.
//<br><br>
//<b>See also: </b>
//fd.buffernum,
//fd.getbuffer,
//fd.setbuffer,
//fd.getsector,
//fd.checksum,
//fd.copyfirmware
//--------------------------------------------------------------------
Object.defineProperty(fd, 'totalsize', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD).</b><br><br>
//Returns the total number of sectors occupied by the currently existing flash disk.
//<br><br>
//Actual usable capacity (fd.capacity) of the disk is less because the disk also needs a number of sectors for its "housekeeping" data (see fd.numservicesectors).
//<br><br>
//The disk must be mounted (see fd.mount) for this property to return a meaningful value.
//<br><br>
//<b>See also: </b>
//fd.capacity, fd.numservicesectors, fd.getfreespace, fd.maxstoredfiles, fd.getnumfiles
//--------------------------------------------------------------------
Object.defineProperty(fd, 'leveling', {
    get() { return 0; },
    set() { }
});
//--------------------------------------------------------------------
Object.defineProperty(fd, 'errordata', {
    get() { return 0; },
    set() { }
});
//--------------------------------------------------------------------
Object.defineProperty(fd, 'transactioncapacityremaining', {
    get() { return 16; },
    set() { }
});
//<b>R/O PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0 (0 sectors).</b><br><br>
//Returns the number of sectors that can still be changed in the cause of the current disk transaction.
//<br><br>
//At the beginning of the transaction (after fd.transactionstart) this property is at its maximum. This maximum is maxjournalsectors-1 or 16, whichever is smaller.
//Maxjournalsectors is the argument of fd.formatj.
//<br><br>
//As the program performs disk write operations, the value of this property decreases. If no free journal memory left, the disk operation will return
//PL_FD_STATUS_TRANSACTION_CAPACITY_EXCEEDED error (fatal).
//<br><br>
//<b>See also: </b>
//fd.transactioncommit,fd.transactionstarted 
//--------------------------------------------------------------------
fd.transactioncommit = function () { };
//<b>METHOD. </b><br><br>
//Commits a disk transaction that was previously started with the fd.transactionstart method.
//<br><br>
//At this point all changes to the disk data that were made in the cause of this transaction are written back to the disk. 
//<br><br>
//<b>See also: </b>
//fd.transactionstarted, fd.transactioncapacityremaining
//--------------------------------------------------------------------
fd.transactionstart = function () { };
//<b>METHOD. </b><br><br>
//Starts a disk transaction.
//<br><br>
//The disk will only accept transactions if it was formatted with the fd.formatj method and the maxjournalsectors argument was >1.
//<br><br>
//All disk writes within the transaction are stored in the so called journal memory and are only
//written to the disk when fd.transactioncommit is executed.
//<br><br>
//<b>See also: </b>
//fd.transactionstarted, fd.transactioncapacityremaining
//--------------------------------------------------------------------
Object.defineProperty(fd, 'transactionstarted', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0- NO (transaction hasn't been started yet).</b><br><br>
//Reports whether a disk transaction is currently in progress.
//<br><br>
//Use fd.transactionstart and fd.transactioncommit to start and finish disk transactions.
//<br><br>
//<b>See also: </b>
//fd.transactioncapacityremaining
//--------------------------------------------------------------------
//Keytroller
fd.copymonitor = function (x1, x2, x3, x4) { };
//**************************************************************************************************
//       TPRAM (Tamper-proof non-volatile RAM) object
//**************************************************************************************************
//--------------------------------------------------------------------
Object.defineProperty(tpram, 'triggerpolarity', {
    get() { return 0; },
    set() { }
});
//--------------------------------------------------------------------
Object.defineProperty(tpram, 'tamperdetection', {
    get() { return 0; },
    set() { }
});
//--------------------------------------------------------------------
Object.defineProperty(tpram, 'timestamping', {
    get() { return 0; },
    set() { }
});
//--------------------------------------------------------------------
Object.defineProperty(tpram, 'capacity', {
    get() { return 0; },
    set() { }
});
//--------------------------------------------------------------------
tpram.getdata = function (startaddr, len) { };
//<b>METHOD. </b><br><br> 
//--------------------------------------------------------------------
tpram.setdata = function (datatoset, startaddr) { };
//<b>METHOD. </b><br><br> 
//--------------------------------------------------------------------
tpram.gettimestamp = function (daycount, mincount, seconds, overflow) { };
//**************************************************************************************************
//       WLN (Wi-Fi) object
//**************************************************************************************************
//The wln. object represents the Wi-Fi interface of your device. This object is responsible for finding and associating with Wi-Fi networks, as well as for creating your own network.
//It also specifies various parameters related to the Wi-Fi interface (IP address, default gateway IP, netmask, etc.).  The object is not in charge of
//sending/transmitting data. The latter is the job of the sock. object.
//<br><br>
//The wln. object is designed to work with the GA1000 and WA2000 devices.
//--------------------------------------------------------------------
wln.activescan = function (ssid) { };
//<b>METHOD.</b>
//<b>METHOD.</b>
//<br><br>
//Causes the Wi-Fi interface to commence either the active detection of available wireless networks or obtainment of an additional information about a particular network specified by its SSID (name).
//<br><br>
//<b>Ssid </b>-- Network name. Leave empty to scan for all available networks -- after the scan, the comma-delimited list of networks will be in wln.scanresultssid.
//Alternatively, specify the network name. If the network is found, its parameters will be available through
//wln.scanresultssid, wln.scanresultbssid, wln.scanresultbssmode, wln.scanresultchannel, wln.scanresultrssi, and wln.scanresultwpainfo.
//<br><br>
//Active scanning is limited to frequency bands and modes allowed by the wln.band property, as well as the current domain (wln.domain).
//<br><br>
//The scan process is a "task". As such, wln.scan will be rejected (return 1- REJECTED) if another task is currently in progress.
//The task will also be rejected if the Wi-Fi interface is not operational (wln.enabled=0- NO).
//<br><br>
//The task is completed when wln.task becomes 0- PL_WLN_TASK_IDLE. The on_wln_task_complete event is also generated at that time and the values of related R/O properties are updated. 
//<br><br>
//Scanning while the Wi-Fi interface is in the associated state (wln.associationstate= 1- PL_WLN_ASSOCIATED) or running its own network
//(wln.associationstate= 2- PL_WLN_OWN_NETWORK) will temporarily disrupt communications between your device and other stations.
//--------------------------------------------------------------------
//<b>PLATFORM CONSTANT.</b><br><br> Infrastructure mode.
//<b>PLATFORM CONSTANT.</b><br><br> Ad-hoc (device-to-device) mode.
//--------------------------------------------------------------------
wln.associate = function (bssid, ssid, channel, bssmode) { };
//<b>METHOD.</b>
//<br><br>
//Causes the Wi-Fi interface to attempt association with the specified wireless network.
//<br><br>
//<b>Bssid </b>--
//GA1000: This argument must contain the actual BSSID ("MAC address") of the target network.
//WA2000: Provide the BSSID of the target network or set this argument to "" or "0.0.0.0.0.0" to allow the wln. object associate with any network with matching SSID. 
//<br><br>
//<b>Ssid </b>-- The name of the target network with which to associate.
//<br><br>
//<b>Channel </b>--
//GA1000: This argument must contain the correct channel on which the target network operates.
//WA2000: Provide the correct channel or set this argument to 0 to allow the wln. object associate with the target network on any channel.
//<br><br>
//<b>Bssmode </b>-- Network mode of the target network (infrastructure or ad-hoc).
//GA1000 can associate with infrastructure and ad-hoc networks.
//WA2000 can only associate with infrastructure networks. For it, this argument should always be set to 0- PL_WLN_BSS_MODE_INFRASTRUCTURE.
//<br><br>
//Association is a task. As such, it will only be accepted when no other task is being executed (wln.task= 0- WLN_TASK_IDLE).
//Task completion does not guarantee success. After the task completes, verify association status through the wln.associationstate R/O property.
//<br><br>
//Wi-Fi security (wln.wep, wln.wpa) must be set before attempting to associate.
//<br><br>
//Association is a complex subject. It is difficult to explain everything there is to explain in a tooltip like this.
//To get more information (and there is <i>a lot </i>of information to get!), highlight wln.associate in your code and press F1.  
//--------------------------------------------------------------------
//<b>PLATFORM CONSTANT.</b><br><br> The Wi-Fi interface is idle.
//<b>PLATFORM CONSTANT.</b><br><br> The Wi-Fi interface is associated with a wireless network.
//<b>PLATFORM CONSTANT.</b><br><br> The Wi-Fi interface is running its own ad-hoc network.   
Object.defineProperty(wln, 'associationstate', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0- PL_WLN_NOT_ASSOCIATED (the Wi-Fi interface is idle). </b>
//<br><br>
//Indicates whether the Wi-Fi interface is idle, associated with another network, or running its own network.
//<br><br>
//After the successful association, which is initiated through the wln.associate method, the value of this property changes to 
//1- PL_WLN_ASSOCIATED. The value is reset back to 0- PL_WLN_NOT_ASSOCIATED if disassociation occurs (on_wln_event will be generated too).
//<br><br>
//After the Wi-Fi interface succeeds in creating its own network (see wln.networkstart), the value of this property becomes 2- PL_WLN_OWN_NETWORK.
//The value is reset back to 0- PL_WLN_NOT_ASSOCIATED when the network is terminated with wln.networkstop.
//--------------------------------------------------------------------
//2.4GHz band, 802.11b/g. 
//2.4GHz band, 802.11b. 
//5GHz band, 802.11a. 
//2.4G and 5G band, 802.11a/b/g. 
//2.4GHz band, 802.11g. 
//2.4G and 5G band (default), 802.11a/b/g/n. 
//11n-only with 2.4GHz band, 802.11n. 
//2.4GHz band, 802.11g/n. 
//5GHz band, 802.11a/n. 
//2.4GHz band, 802.11b/g/n. 
//2.4G and 5G band, 802.11a/g/n. 
//11n-only with 5GHz band, 802.11n. 
//--------------------------------------------------------------------
wln.boot = function (offset) { };
//<b>METHOD.</b>
//<br><br>
//Boots up the Wi-Fi add-on module.
//<br><br>
//<b>Offset </b>--
//GA1000: Offset of the <i>ga1000fw.bin </i>file within the compiled binary of your project. The offset is obtained using the romfile.offset R/O property.
//WA2000: Must be set to 0 (this module stores its firmware in its flash memory and does not require the firmware file to be uploaded on every boot).
//<br><br>
//The method will return 0- OK if the boot was completed successfully. At that moment, wln.enabled will become 1- YES.
//<br><br>
//The boot will fail (return 1- NG) if the Wi-Fi hardware is not powered, not properly reset, connected improperly, mapped incorrectly, or malfunctioned.
//<br><br>
//On the GA1000, the method will also fail if the offset to the firmware file is incorrect or the file is not included in your project.
//On the WA2000, the method will fail if the offset is anything but 0.
//<br><br>
//Finally, the method will fail if the Wi-Fi hardware is already booted and operational.
//--------------------------------------------------------------------
wln.buffrq = function (numpages) { };
//<b>METHOD.</b>
//<br><br>
//Pre-requests a number of buffer pages (1 page= 256 bytes) for the TX buffer of the wln. object.
//<br><br>
//<b>Numpages </b>-- Requested numbers of buffer pages to allocate (recommended value is <b>5</b>).
//<br><br>
//Returns the actual number of pages that can be allocated. Allocation happens when the sys.buffalloc is executed. The wln object
//will be unable to operate properly if its TX buffer has inadequate capacity.
//<br><br>
//Buffer allocation will not work if the Wi-Fi hardware is already operational (wln.enabled= 1- YES).
//--------------------------------------------------------------------
Object.defineProperty(wln, 'buffsize', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD | DWORD), DEFAULT VALUE= 0 (0 bytes).</b>
//<br><br>
//Returns the current capacity (in bytes) of the wln object's TX buffer.
//<br><br>
//Buffer capacity is set using wln.buffrq method.
//--------------------------------------------------------------------
Object.defineProperty(wln, 'clkmap', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE= PL_IO_NULL (NULL line). </b>
//<br><br>
//Sets/returns the number of the GPIO line acting as the clock (CLK) line of the Wi-Fi module's SPI interface. The line is selected from
//the pl_io_num list.
//<br><br>
//This selection cannot be changed once the Wi-Fi hardware is already operational (wln.enabled= 1- YES).
//<br><br>
//This property has no effect on the EM500W platform.
//--------------------------------------------------------------------
Object.defineProperty(wln, 'csmap', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE= PL_IO_NULL (NULL line). </b>
//<br><br>
//Sets/returns the number of the GPIO line acting as the chip select (CS) line of the Wi-Fi module's SPI interface. The line is selected from
//the pl_io_num list.
//<br><br>
//This selection cannot be changed once the Wi-Fi hardware is already operational (wln.enabled= 1- YES).
//<br><br>
//This property has no effect on the EM500W platform.
//--------------------------------------------------------------------
Object.defineProperty(wln, 'dimap', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE= PL_IO_NULL (NULL line). </b>
//<br><br>
//Sets/returns the number of the GPIO line acting as the data in (DI) line of the Wi-Fi module's SPI interface. The line is selected from
//the pl_io_num list.
//<br><br>
//The selection cannot be changed once the Wi-Fi hardware is already operational (wln.enabled= 1- YES).
//<br><br>
//This DI line must be connected to the DO pin of the GA1000.
//<br><br>
//This property has no effect on the EM500W platform.
//--------------------------------------------------------------------
wln.disassociate = function () { };
//<b>METHOD.</b>
//<br><br>
//Causes the Wi-Fi interface to commence disassociation from a wireless network.
//<br><br>
//The disassociation process is a task. As such, it will be rejected if another task is currently in progress (wln.task <> 0- WLN_TASK_IDLE).
//<br><br>
//Wln.disassociate will also be rejected if the Wi-Fi interface is not operational (wln.enabled=0- NO) or
//if the Wi-Fi interface is not currently associated (wln.associationstate <> 1- PL_WLN_ASSOCIATED).
//--------------------------------------------------------------------
//<b>PLATFORM CONSTANT.</b><br><br> FCC (US), default. GA1000: channels 1-11 of the 2.4GHz range; WA2000: the same plus channels 52-64, 100-140, 149-165 of the 5.0GHz range.
//<b>PLATFORM CONSTANT.</b><br><br> European Union. GA1000: channels 1-13 of the 2.4GHz range; WA2000: the same plus channels 52-64, 100-140, 149-165 of the 5.0GHz range. 
//<b>PLATFORM CONSTANT.</b><br><br> Japan. GA1000: channels 1-14 of the 2.4GHz range; WA2000: the same plus channels 34-36 of the 5.0GHz range. 
//--------------------------------------------------------------------
Object.defineProperty(wln, 'domain', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0- PL_WLN_DOMAIN_FCC. </b>
//<br><br>
//Selects the domain (area of the world) in which this device is operating. This defines the list of channels on which the Wi-Fi interface
//will be allowed to active-scan (wln.activescan) or associate (wln.associate) with wireless networks.
//<br><br>
//Passive scanning (wln.scan) is performed on all channels of enabled bands (wln.band), regardless of the value of wln.domain.
//<br><br>
//This property can't be changed while the Wi-Fi hardware is operational (wln.enabled= 1- YES).
//--------------------------------------------------------------------
Object.defineProperty(wln, 'domap', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE= PL_IO_NULL (NULL line). </b>
//<br><br>
//Sets/returns the number of the GPIO line acting as the data out (DO) line of the Wi-Fi module's SPI interface. The line is selected from
//the pl_io_num list.
//<br><br>
//The selection cannot be changed once the Wi-Fi hardware is already operational (wln.enabled= 1- YES).
//<br><br>
//This DO line must be connected to the DI pin of the GA1000.
//<br><br>
//This property has no effect on the EM500W platform.
//--------------------------------------------------------------------
Object.defineProperty(wln, 'enabled', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0- NO.</b>
//<br><br>
//Indicates whether the Wi-Fi interface is operational.
//<br><br>
//The Wi-Fi hardware becomes operational after a successful boot using the wln.boot method, at which time wln.enabled is set to 1- YES.
//<br><br>
//The Wi-Fi interface is disabled and the wln.enabled is reset to 0- NO if wln.disable is called, or the Wi-Fi hardware is disconnected, powered down, malfunctioned,
//or was intentionally reset. In all these cases the on_wln_event(0- PL_WLN_EVENT_DISABLED) event is generated, too.
//--------------------------------------------------------------------
Object.defineProperty(wln, 'gatewayip', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (STRING), DEFAULT VALUE= "0.0.0.0". </b><br><br>
//Sets/returns the IP address of the default gateway for the Wi-Fi interface of your device.
//<br><br>
//This property can only be written to when no socket is engaged in communicating through the Wi-Fi interface, i.e. there is no socket for which
//sock.statesimple <> 0- PL_SSTS_CLOSED and sock.currentinterface = 2- PL_INTERFACE_WLN.
//--------------------------------------------------------------------
//--------------------------------------------------------------------
//Main firmware region.
//Monitor/Loader firmware region.
//T1000 Based Devices and EM500W
//--------------------------------------------------------------------
wln.getmoduletype = function () { };
//<b>R/O PROPERTY (BYTE, ENUM). </b><br><br>
//Detects and returns the Wi-Fi module type, or just returns the module type if it has already been detected earlier.
//<br><br>
//The actual module type detection happens on the first invocation of wln.getmoduletype or wln.boot, whichever is called first after the reset of the Wi-Fi module.
//<br><br>
//Wln.getmoduletype also has a side job -- it can be used to boot the WA2000 into the Monitor/Loader, which is necessary for performing firmware updates.
//--------------------------------------------------------------------
Object.defineProperty(wln, 'monversion', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (STRING). </b><br><br>
//For the WA2000 Wi-Fi/BLE add-on, returns the version string of the module's Monitor/Loader.
//<br><br>
//This property starts returning the Monitor/Loader version after the WA2000 is booted (wln.boot) or after the Wi-Fi module type is detected (wln.getmoduletype).
//<br><br>
//When the GA1000 device is used, this property always returns an empty string.
//--------------------------------------------------------------------
Object.defineProperty(wln, 'fwversion', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (STRING). </b><br><br>
//For the WA2000 Wi-Fi/BLE add-on, returns the version string of the module's main firmware.
//<br><br>
//This property starts returning the firmware version after the WA2000 is booted (wln.boot) or after the Wi-Fi module type is detected (wln.getmoduletype).
//<br><br>
//When the GA1000 device is used, this property always returns an empty string.
//--------------------------------------------------------------------
wln.disable = function () { };
//<b>METHOD. </b><br><br>
//Causes the wln. object to be disabled.
//<br><br>
//Disabling the wln. object is not the same as shutting down the Wi-Fi module. Disabling the wln. object means that TiOS stops servicing it.
//The Wi-Fi module itself continues to run. To shut the Wi-Fi module down, put it in reset.   
//<br><br>
//Note that the object does not become disabled immediately upon invoking wln.disable. To detect when this actually happens, poll the value of wln.enabled until it becomes 0- NO.
//Alternatively, wait for the on_wln_event(0- PL_WLN_EVENT_DISABLED) event -- it is generated when the wln. object is disabled.
//<br><br>
//You can enable the wln. object again by resetting the Wi-Fi module and calling wln.boot.
//--------------------------------------------------------------------
wln.setupgraderegion = function (region) { };
//<b>METHOD. </b><br><br>
//For the WA2000 Wi-Fi/BLE add-on, specifies what region (portion) of the WA2000's firmware is going to be upgraded -- the main firmware or the Monitor/Loader.
//<br><br>
//The algorithm of upgrading the firmware of the WA2000 is rather complex and it is not possible to explain it in tooltips. For more information see
//<b>TIDE, TiOS, Tibbo BASIC and Tibbo C Manual</b> (you can access it by pressing F1 in TIDE) <b>-> THE REFERENCE -> Objects -> Wln Object -> Overview -> Updating Firmware (WA2000 only)</b>. 
//<br><br>
//Invoking this method while using the GA1000 device will have no effect.
//--------------------------------------------------------------------
wln.writeflashpage = function (page) { };
//<b>METHOD. </b><br><br>
//For the WA2000 Wi-Fi/BLE add-on, sends a 128-byte page (block) of firmware data into the module. The method should be called repeatedly until the entire firmware "file" has been uploaded onto the WA2000.
//<br><br>
//The algorithm of upgrading the firmware of the WA2000 is rather complex and it is not possible to explain it in tooltips. For more information see
//<b>TIDE, TiOS, Tibbo BASIC and Tibbo C Manual</b> (you can access it by pressing F1 in TIDE) <b>-> THE REFERENCE -> Objects -> Wln Object -> Overview -> Updating Firmware (WA2000 only)</b>. 
//<br><br>
//Invoking this method while using the GA1000 device will have no effect. 
//--------------------------------------------------------------------
wln.upgrade = function (region, fwlength, checksum) { };
//<b>METHOD. </b><br><br>
//For the WA2000 Wi-Fi/BLE add-on, initiates copying of the firmware "file" (that was uploaded onto the WA2000 using wln.writeflashpage) from the spare area into the target region of the module's flash memory. The target region 'is selected with wln.setupgraderegion.
//<br><br>
//The algorithm of upgrading the firmware of the WA2000 is rather complex and it is not possible to explain it in tooltips. For more information see
//<b>TIDE, TiOS, Tibbo BASIC and Tibbo C Manual</b> (you can access it by pressing F1 in TIDE) <b>-> THE REFERENCE -> Objects -> Wln Object -> Overview -> Updating Firmware (WA2000 only)</b>. 
//<br><br>
//Invoking this method while using the GA1000 device will have no effect.
//--------------------------------------------------------------------
wln.waitforupgradecompletion = function () { };
//<b>METHOD. </b><br><br>
//For the WA2000 Wi-Fi/BLE add-on, waits for the firmware copying to complete and returns the result of the copying process. Firmware copying is initiated using wln.upgrade.
//<br><br>
//The algorithm of upgrading the firmware of the WA2000 is rather complex and it is not possible to explain it in tooltips. For more information see
//<b>TIDE, TiOS, Tibbo BASIC and Tibbo C Manual</b> (you can access it by pressing F1 in TIDE) <b>-> THE REFERENCE -> Objects -> Wln Object -> Overview -> Updating Firmware (WA2000 only)</b>. 
//<br><br>
//Invoking this method while using the GA1000 device will have no effect.
//--------------------------------------------------------------------
Object.defineProperty(wln, 'band', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE= 5- WIFI_PHY_11ABGN_MIXED (2.4G and 5G bands, 802.11a/b/g/n).</b>
//<br><br>
//Specifies what frequency bands (2.4GHz, 5.0GHz, or both) and 802.11 communications standards ("a", "b", "g", "n" or combinations thereof) are enabled.
//<br><br>
//Since the GA1000 device only supports 2.4GHz "b" and "g" modes, the value of this property is reset to 0- WIFI_PHY_11BG_MIXED as soon as the wln.boot or wln.getmoduletype method is executed (and the Wi-Fi module type is detected).
//<br><br>
//The value of this property cannot be changed when the wln.enabled R/O property is at 1- ENABLED (the wln.boot method has been executed). 
//--------------------------------------------------------------------
Object.defineProperty(wln, 'ip', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (STRING), DEFAULT VALUE= "1.0.0.1". </b><br><br>
//Sets/returns the IP address of the Wi-Fi interface of your device.
//<br><br>
//This property can only be written to when no socket is engaged in communicating through the Wi-Fi interface, i.e. there is no socket for which
//sock.statesimple <> 0- PL_SSTS_CLOSED and sock.currentinterface = 2- PL_INTERFACE_WLN.
//--------------------------------------------------------------------
Object.defineProperty(wln, 'mac', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (STRING), DEFAULT VALUE= "0.0.0.0.0.0". </b>
//<br><br>
//Sets/returns the MAC address of the Wi-Fi interface.
//<br><br>
//This property can only be written to while the Wi-Fi hardware is not operational (wln.enabled= 0- NO).
//<br><br>
//Each GA1000 and WA2000 device carries a unique MAC address.
//To use this internal MAC of the module, do not write to this property. After a successful boot, wln.mac will contain the MAC address obtained from the Wi-Fi module.
//<br><br>
//Alternatively, set your own MAC address before calling wln.boot. This MAC address, and not the internal MAC of the Wi-Fi module will
//be used (but only until the module is rebooted). The MAC address hardcoded into the module is never overwitten or erased.
//--------------------------------------------------------------------
Object.defineProperty(wln, 'netmask', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (STRING), DEFAULT VALUE= "0.0.0.0". </b><br><br>
//Sets/returns the netmask of the Wi-Fi interface of your device.
//<br><br>
//This property can only be written to when no socket is engaged in communicating through the Wi-Fi interface, i.e. there is no socket for which
//sock.statesimple <> 0- PL_SSTS_CLOSED and sock.currentinterface = 2- PL_INTERFACE_WLN.
//--------------------------------------------------------------------
wln.networkstart = function (ssid, channel) { };
//<b>METHOD.</b>
//<br><br>
//Causes the Wi-Fi interface to commence creating its own network.
//<br><br>
//<b>Ssid </b>-- The name of the network to create.
//<br><br>
//<b>Channel </b>-- Channel on which the new network will operate.
//<br><br>
//Network creation process is a task. As such, wln.networkstart will be rejected (return 1- REJECTED) if another task is currently in progress.
//The task will also be rejected if the Wi-Fi hardware is not operational (wln.enabled=0- NO) or if
//the Wi-Fi interface is already non-idle (wln.associationstate <> 0- PL_WLN_NOT_ASSOCIATED).
//<br><br>
//The task is completed when wln.task becomes 0- PL_WLN_TASK_IDLE. The on_wln_task_complete event is also generated at that time. 
//Completion does not imply success -- the result has to be verified by reading the state of the wln.associationstate R/O property.
//--------------------------------------------------------------------
wln.networkstop = function () { };
//<b>METHOD.</b>
//<br><br>
//Causes the Wi-Fi interface to commence the termination of its own network.
//<br><br>
//Network termination process is a task. As such, wln.networkstop will be rejected (return 1- REJECTED) if another task is currently in progress.
//The task will also be rejected if the Wi-Fi hardware is not operational (wln.enabled=0- NO) or the Wi-Fi interface is not currently running own network (wln.assiciationstate <> 2- PL_WLN_OWN_NETWORK).
//<br><br>
//The task is completed when wln.task becomes 0- PL_WLN_TASK_IDLE. The on_wln_task_complete event is also generated at that time.
//--------------------------------------------------------------------
//<b>PLATFORM CONSTANT.</b><br><br>Wi-Fi hardware has been disconnected, powered-down, reset, or is malfunctioning.
//<b>PLATFORM CONSTANT.</b><br><br>Wi-Fi interface has been disassociated from the wireless network.
//<b>EVENT of the wln object.</b>
//<br><br>
//Generated when the wln. object detects disassociation from the wireless network, the Wi-Fi interface is disabled by calling wln.disable,
//or the Wi-Fi hardware is disconnected, powered-down, reset, or have malfunctioned.
//<br><br>
//<b>Wln_event </b>-- registered event (DISABLED or DISASSOCIATED).
//<br><br>
//Multiple on_wln_event events may be waiting in the event queue.
//For this reason the doevents statement will be skipped (not executed) if encountered within the event handler
//for this event or the body of any procedure in the related call chain.
//--------------------------------------------------------------------
//<b>PLATFORM CONSTANT.</b><br><br>No task (idle). 
//<b>PLATFORM CONSTANT.</b><br><br>Passive scan task.
//<b>PLATFORM CONSTANT.</b><br><br>Association task.
//<b>PLATFORM CONSTANT.</b><br><br>TX power adjustment task (completes immediately).
//<b>PLATFORM CONSTANT.</b><br><br>WEP mode and keys setup task (completes immediately).
//<b>PLATFORM CONSTANT.</b><br><br>Disassociation task.
//<b>PLATFORM CONSTANT.</b><br><br>Network start task.
//<b>PLATFORM CONSTANT.</b><br><br>Network stop task.
//<b>PLATFORM CONSTANT.</b><br><br>WPA mode and keys setup task (completes immediately). 
//<b>PLATFORM CONSTANT.</b><br><br>Active scan task.
//<b>PLATFORM CONSTANT.</b><br><br>RSSI update task.
//<b>PLATFORM CONSTANT.</b><br><br>EAP-TLS mode and keys setup task (completes immediately). 
//<b>PLATFORM CONSTANT.</b><br><br>EAP-PEAP mode and keys setup task (completes immediately). 
//<b>PLATFORM CONSTANT.</b><br><br>EAP-TTLS mode and keys setup task (completes immediately).     
//<b>EVENT of the wln object.</b>
//<br><br>
//Generated when the Wi-Fi interface completes executing a given task.
//<br><br>
//<b>Wln_event </b>-- the task completed.
//<br><br>
//The wln.task R/O property will change to 0- PL_WLN_TASK_IDLE along with this event generation.
//The wln object will only accept another task for execution after the previous task has been completed.
//<br><br>
//Multiple on_wln_task_complete events may be waiting in the event queue.
//For this reason the doevents statement will be skipped (not executed) if encountered within the event handler
//for this event or the body of any procedure in the related call chain.
//--------------------------------------------------------------------
Object.defineProperty(wln, 'rssi', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (BYTE), DEFAULT VALUE= 0.</b>
//<br><br>
//Indicates the strength of the signal being received from the wireless peer.
//<br><br>
//The signal strength is expressed in 256 arbitrary levels that do not correspond to any standard measurement unit.
//<br><br>
//This property is only updated while the Wi-Fi interface is in the non-idle state (wln.associationstate <> 0- PL_WLN_NOT_ASSOCIATED).
//--------------------------------------------------------------------
//<b>METHOD.</b>
//<br><br>
//Causes the Wi-Fi interface to commence RSSI value updating.
//--------------------------------------------------------------------
wln.scan = function (ssid) { };
//<b>METHOD.</b>
//<br><br>
//Causes the Wi-Fi interface to commence either the passive detection of available wireless networks or obtainment of an additional information about a particular network specified by its SSID (name).
//<br><br>
//<b>Ssid </b>-- Network name. Leave empty to scan for all available networks -- after the scan, the comma-delimited list of networks will be in wln.scanresultssid.
//Alternatively, specify the network name. If the network is found, its parameters will be available through
//wln.scanresultssid, wln.scanresultbssid, wln.scanresultbssmode, wln.scanresultchannel, wln.scanresultrssi, and wln.scanresultwpainfo.
//<br><br>
//Scanning is limited to frequency bands and modes allowed by the wln.band property.
//<br><br>
//The scan process is a "task". As such, wln.scan will be rejected (return 1- REJECTED) if another task is currently in progress.
//The task will also be rejected if the Wi-Fi interface is not operational (wln.enabled=0- NO).
//<br><br>
//The task is completed when wln.task becomes 0- PL_WLN_TASK_IDLE. The on_wln_task_complete event is also generated at that time and the values of related R/O properties are updated. 
//<br><br>
//Scanning while the Wi-Fi interface is in the associated state (wln.associationstate= 1- PL_WLN_ASSOCIATED) or running its own network
//(wln.associationstate= 2- PL_WLN_OWN_NETWORK) will temporarily disrupt communications between your device and other stations.
//--------------------------------------------------------------------
//<b>PLATFORM CONSTANT.</b><br><br> Scan for infrastructure and ad-hoc networks.
//<b>PLATFORM CONSTANT.</b><br><br> Scan for infrastructure networks only.
//<b>PLATFORM CONSTANT.</b><br><br> Scan for ad-hoc networks only.
Object.defineProperty(wln, 'scanfilter', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0- PL_WLN_SCAN_ALL. </b>
//<br><br>
//Determines what wireless networks are included in the scan results (after scanning with wln.scan or wln.activescan): all networks, only infrastructure networks (access points), or only ad-hoc networks.
//<br><br>
//Note that WA2000 does not support association with ad-hoc networks.
//--------------------------------------------------------------------
Object.defineProperty(wln, 'scanresultbssid', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (STRING), DEFAULT VALUE= "".</b>
//<br><br>
//After a successful scan for a particular network (wln.scan or wln.activescan with the SSID specified) this property will contain the BSSID ("MAC address") of this network. 
//<br><br>
//This property will not be updated if wln.scan or wln.activescan is invoked with its ssid argument left empty ("search for all networks" mode).
//--------------------------------------------------------------------
Object.defineProperty(wln, 'scanresultbssmode', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0- PL_WLN_BSS_MODE_INFRASTRUCTURE.</b>
//<br><br>
//After a successful scan for a particular network (wln.scan with the ssid specified) this property will contain the network mode of this network
//(infrastructure or ad-hoc).
//<br><br>
//This property will not be updated if wln.scan or wln.activescan is invoked with its ssid argument left empty ("search for all networks" mode).
//--------------------------------------------------------------------
Object.defineProperty(wln, 'scanresultchannel', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (BYTE), DEFAULT VALUE= 1 (channel 1).</b>
//<br><br>
//After a successful scan for a particular network (wln.scan with the ssid specified) this property will contain the number of the channel on which this network operates.
//<br><br>
//This property will not be updated if wln.scan or wln.activescan is invoked with its ssid argument left empty ("search for all networks" mode).
//--------------------------------------------------------------------
Object.defineProperty(wln, 'scanresultrssi', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (BYTE), DEFAULT VALUE= 0.</b>
//<br><br>
//After a successful scan for a particular network (wln.scan with the ssid specified) this property will contain the strength of the signal received from this network.
//<br><br>
//This property will not be updated if wln.scan or wln.activescan is invoked with its ssid argument left empty ("search for all networks" mode).
//<br><br>
//The signal strength is expressed in 256 arbitrary levels that do not correspond to any standard measurement unit.
//--------------------------------------------------------------------
Object.defineProperty(wln, 'scanresultssid', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (STRING), DEFAULT VALUE= "".</b>
//<br><br>
//After a scan (wln.scan or wln.activescan) this property will contain a comma-delimited list of discovered networks or the name of a particular network depending on how the scan was performed.
//<br><br>
//If the wln.scan or wln.activescan method was invoked with its name argument left empty, this property will contain the list of all discovered networks.
//If the name argument specified a particular network and scanning found this network to be present, then this property will contain the name of this network
//(otherwise an empty string will be returned).
//--------------------------------------------------------------------
Object.defineProperty(wln, 'scanresultwpainfo', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (STRING), DEFAULT VALUE= "".</b>
//<br><br>
//On GA1000, after a successful scan for a particular network (wln.scan or wln.activescan with the SSID specified) this property will contain binary data required for WPA/WPA2 security protocol.
//The property always returns an empty string on WA2000.
//<br><br>
//This property will not be updated if the wln.scan method is invoked with its ssid argument left empty ("search for all networks" mode).
//<br><br>
//The string returned by this property is not intended for humans. The property exists to facilitate the operation of the WLN library, which calculates the WPA key for the GA1000.
//--------------------------------------------------------------------
wln.settxpower = function (level) { };
//<b>METHOD.</b>
//<br><br>
//Causes the Wi-Fi interface to commence the adjustment of the TX power to the specified level.
//<br><br>
//<b>Level </b>-- Value between 4 and 15 that roughly corresponds to the transmitter's output power in dB.
//Attempting to specify the level < 4 results in level = 4; attempting to specify the level > 15 results in level = 15.
//<br><br>
//Adjusting TX power is an immediate task. As such, wln.settxpower will be rejected (return 1- REJECTED) if another task is currently in progress.
//The task will also be rejected if the Wi-Fi hardware is not online (wln.enabled= 0- NO).
//<br><br>
//"Immediate" means you don't have to wait for the task to complete -- it is finished as soon as wln.settxpower is done executing.
//The on_wln_task_complete event is still generated.
//--------------------------------------------------------------------
//<b>PLATFORM CONSTANT.</b><br><br>WEP is disabled.
//<b>PLATFORM CONSTANT.</b><br><br>WEP-64 is enabled.
//<b>PLATFORM CONSTANT.</b><br><br>WEP-128 is enabled.
wln.setwep = function (wepkey, wepmode) { };
//<b>METHOD.</b>
//<br><br>
//Causes the Wi-Fi interface to set new WEP mode and key.
//<br><br>
//<b>Wepkey </b>-- A string containing the new WEP key. This is a "HEX strings" -- each character in the string represents one HEX digit.
//The string must contain 10 HEX digits for WEP64 and 26 HEX digits for WEP128. Any data in excess of these lengths is ignored. Missing digits are assumed to be 0.
//<br><br>
//<b>Wepmode </b>-- choose between "disabled", "WEP64", or "WEP128".
//<br><br>
//The WEP mode must be set prior to performing association (wln.associate) or starting own network (wln.networkstart).
//If you are switching from an access point using WEP security to another access point with no security or WPA security, you still need to execute wln.setwep("",PL_WLN_WEP_MODE_DISABLED).
//<br><br>
//Only one WEP key (wepkey1) is used by the wln. object.
//<br><br>
//Changing WEP mode and keys is an immediate task.
//This task completes as soon as wln.setwep finishes executing.
//The on_wln_task_complete event is still generated.
//<br><br> 
//The task will be rejected if the Wi-Fi interface is not operational (wln.enabled= 0- NO).
//--------------------------------------------------------------------
//<b>PLATFORM CONSTANT.</b><br><br>WPA disabled.
//<b>PLATFORM CONSTANT.</b><br><br>WPA1-PSK mode.
//<b>PLATFORM CONSTANT.</b><br><br>WPA2-PSK mode.
//<b>PLATFORM CONSTANT.</b><br><br>Install TKIP key.
//<b>PLATFORM CONSTANT.</b><br><br>Install AES key.
//<b>PLATFORM CONSTANT.</b><br><br>Install unicast key.
//<b>PLATFORM CONSTANT.</b><br><br>Install multicast key.
wln.setwpa = function (wpamode, algorithm, wpakey, cast) { };
//<b>METHOD.</b>
//<br><br>
//Causes the Wi-Fi interface to commence setting new WPA mode and key.
//<br><br>
//<b>Wpamode </b>-- choose between "disabled", "WPA1", or "WPA2".
//<br><br>
//<b>Algorithm </b>-- choices are "TKIP" and "AES".
//<br><br>
//<b>Wpakey </b>-- GA1000: A string containing new WPA key (must be 16 characters long). The key is <i>not</i> the password to your access point. The key is calculated <i>from</i> the password.
//The math involved is complex and is better left to the WLN library that we provide. WA2000: A string containing the password itself. The WA2000 performs the WPA key calculation internally.
//<br><br>
//<b>Cast </b>-- Always set it to 1- PL_WLN_WPA_CAST_MULTICAST.
//<br><br>
//The WPA mode must be set prior to performing association (wln.associate) or starting own network (wln.networkstart).
//If you are switching from an access point using WPA security to another access point with no security or WEP security, you still need to execute wln.setwpa(PL_WLN_WPA_DISABLED,0,"",PL_WLN_WPA_CAST_MULTICAST).
//<br><br>
//Changing WPA mode and keys is an immediate task.
//This task completes as soon as wln.setwpa finishes executing.
//The on_wln_task_complete event is still generated.
//<br><br> 
//The task will be rejected if the Wi-Fi interface is not operational (wln.enabled= 0- NO).
//--------------------------------------------------------------------
Object.defineProperty(wln, 'task', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0- PL_WLN_TASK_IDLE.</b>
//<br><br>
//Indicates the current wln. task being executed.
//<br><br>
//The wln. object will only accept another task for execution after the previous task has been completed
//(wln.task= 0- PL_WLN_TASK_IDLE). Every time the task completes, the on_wln_task_complete event is generated.
//--------------------------------------------------------------------
//--------------------------------------------------------------------
//<b>PLATFORM CONSTANT.</b><br><br>Continuous output.
//<b>PLATFORM CONSTANT.</b><br><br>Burst output.
//<b>PLATFORM CONSTANT.</b><br><br>Continuous output of data.
//<b>PLATFORM CONSTANT.</b><br><br>Rate = 1 Mbps.
//<b>PLATFORM CONSTANT.</b><br><br>Rate = 2 Mbps.
//<b>PLATFORM CONSTANT.</b><br><br>Rate = 5.5 Mbps.
//<b>PLATFORM CONSTANT.</b><br><br>Rate = 11 Mbps.
//<b>PLATFORM CONSTANT.</b><br><br>Rate = 22 Mbps.
//<b>PLATFORM CONSTANT.</b><br><br>Rate = 6 Mbps.
//<b>PLATFORM CONSTANT.</b><br><br>Rate = 9 Mbps.
//<b>PLATFORM CONSTANT.</b><br><br>Rate = 12 Mbps.
//<b>PLATFORM CONSTANT.</b><br><br>Rate = 18 Mbps.
//<b>PLATFORM CONSTANT.</b><br><br>Rate = 24 Mbps.
//<b>PLATFORM CONSTANT.</b><br><br>Rate = 36 Mbps.
//<b>PLATFORM CONSTANT.</b><br><br>Rate = 48 Mbps.
//<b>PLATFORM CONSTANT.</b><br><br>Rate = 54 Mbps.
//<b>PLATFORM CONSTANT.</b><br><br>Rate = 72 Mbps.
//--------------------------------------------------------------------
Object.defineProperty(wln, 'mfgenabled', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0- NO.</b>
//**************************************************************************************************
//       BT (Bluetooth) object
//**************************************************************************************************
//The bt. object represents the BLE interface of your device.
//<br><br>
//The bt. object is designed to work with the WA2000 add-on Wi-Fi/BLE module. For BT (BLE) radio to work, you must first boot the module using the wln.boot method.
//This will enable not only the Wi-Fi, but also the BT (BLE) portion of the WA2000.
//--------------------------------------------------------------------
bt.enable = function () { };
//<b>METHOD. </b><br><br>
//Instructs the WA2000 Wi-Fi/BLE add-on module to turns the BLE radio on. This is an asynchronous method -- it returns control back to the app immediately. On_bt_event(PL_BT_EVENT_ENABLED) is generated when the radio turns on. 
//<br><br>
//This method will only have effect if the WA2000 is booted (wln.boot was called and wln.enabled= 1- YES) and if the BLE radio is currently off (bt.enabled= 0-NO).
//<br><br>
//This method has no effect on the GA1000 device.
//<br><br>
//--------------------------------------------------------------------
bt.disable = function () { };
//<b>METHOD. </b><br><br>
//Instructs the WA2000 Wi-Fi/BLE add-on module to turn the BLE radio off. This is an asynchronous method -- it returns control back to the app immediately. On_bt_event(PL_BT_EVENT_DISABLED) is generated when the radio turns off.
//<br><br>
//This method will only have effect if the WA2000 is booted (wln.boot was called and wln.enabled= 1- YES) and if the BLE radio is currently on (bt.enabled= 1-YES).
//<br><br>
//This method has no effect on the GA1000 device.
//--------------------------------------------------------------------
Object.defineProperty(bt, 'enabled', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0- NO.</b>
//<br><br>
//Informs whether the BLE interface of the Wi-Fi/BLE add-on module is on. The interface turns on after the bt.enable method is invoked. 
//<br><br>
//The BLE interface is disabled and the bt.enabled is reset to 0- NO if the module is disconnected, powered down, malfunctions, or is put in reset.
//When this happens, the on_bt_event(PL_BT_EVENT_DISABLED) event is generated as well.
//--------------------------------------------------------------------
//enum pl_wln_bt_modes
//    PL_WLN_BT_MODE_NOT_SUPPORTED, '<b>PLATFORM CONSTANT.</b><br><br> Bluetooth is not supported by this module.'
//    PL_WLN_BT_MODE_LE	'<b>PLATFORM CONSTANT.</b><br><br> Bluetooth Low Energy Mode.
//PL_WLN_BT_MODE_EDR	'<b>PLATFORM CONSTANT.</b><br><br> Bluetooth Classic Mode.
//end enum
//property bt.mode
//<b>R/O PROPERTY (ENUM, BYTE), DEFAULT VALUE= <font color="olive"><b>0- NO</b></font> PL_WLN_BT_MODE_NOT_SUPPORTED. </b><br>
//The value of this will not be updated until module type has been detected.<br>
//    get = syscall(754) as pl_wln_bt_modes
//    'set = syscall(755) (value as pl_wln_bt_modes)
//end property
//--------------------------------------------------------------------
Object.defineProperty(bt, 'name', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (STRING), DEFAULT VALUE= "". </b><br><br>
//Defines the BLE advertising name. The name can be up to 21 characters long.
//<br><br>
//The value of property can only be changed when bt.advertise is 0- NO.
//<br><br>
//<b>Note that your phone (central device) will typically cache advertising data. </b>
//On iOS, restarting the iOS device will clear the advertising cache. On Android, you can clear the Bluetooth cache via the settings (plus, some applications allow scanning without caching).<br>
//--------------------------------------------------------------------
//property bt.advstring
//<b>PROPERTY (STRING), DEFAULT VALUE= "". </b><br><br>
//<br><br>
//The raw advertising data that is being advertised by the device. 
//<br><br>
//The name change will only take effect after the btadvertise property is toggled to true.
//    get = syscall(758) as string
//    set = syscall(759) (byref btadvstring as string)
//end property
//--------------------------------------------------------------------
//<b>PLATFORM CONSTANT.</b><br><br> Emulates the TI UART-over-BLE service. Not fully supported at this time.
//<b>PLATFORM CONSTANT.</b><br><br> Emulates the NORDIC UART-over-BLE service.
//<b>PLATFORM CONSTANT.</b><br><br> Emulates the Microchip UART-over-BLE service.
Object.defineProperty(bt, 'emulation', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE= 2- PL_WLN_BT_EMULATION_MODE_MICROCHIP. </b><br><br>
//Configures the BLE interface to mimic TI, Nordic, or Microchip BLE devices. 
//<br><br>
//The value of this property can only be changed when bt.enabled= 0- NO (that is, before calling bt.enable).
//--------------------------------------------------------------------
bt.rxbuffrq = function (numpages) { };
//<b>METHOD. </b><br><br>
//Pre-requests the "numpages" number of buffer pages (1 page is 256 bytes) for the RX buffer of the BLE interface. Returns the actual number of pages that can be allocated.
//The actual buffer allocation happens when the sys.buffalloc method is called.
//<br><br>
//The BLE interface is unable to receive data if its RX buffer has zero capacity. Current buffer capacity can be checked through
//bt.rxbuffsize, which returns the buffer capacity in bytes.
//<br><br>
//Relationship between the two is as follows: bt.rxbuffsize = num_pages * 256 - 33 (or =0 when num_pages=0), where
//"num_pages" is the number of buffer pages that was GRANTED through bt.rxbuffrq. "-33" is because a number of bytes is needed for internal buffer
//variables.
//<br><br>
//Buffer allocation will not work if the BLE interface is enabled (bt.enabled= 1- YES at the time when sys.buffalloc executes).
//<br><br>
//The maximum number of pages you can request for this buffer is limited to 255.
//--------------------------------------------------------------------
bt.txbuffrq = function (numpages) { };
//<b>METHOD. </b><br><br>
//Pre-requests the "numpages" number of buffer pages (1 page is 256 bytes) for the TX buffer of the BLE interface. Returns the actual number of pages that can be allocated.
//The actual buffer allocation happens when the sys.buffalloc method is called.
//<br><br>
//The BLE interface is unable to transmit data if its TX buffer has zero capacity. Current buffer capacity can be checked through
//bt.txbuffsize, which returns the buffer capacity in bytes.
//<br><br>
//Relationship between the two is as follows: bt.txbuffsize = num_pages * 256 - 33 (or =0 when num_pages=0), where
//"num_pages" is the number of buffer pages that was GRANTED through bt.txbuffrq. "-33" is because a number of bytes is needed for internal buffer
//variables.
//<br><br>
//Buffer allocation will not work if the BLE interface is enabled (bt.enabled= 1- YES at the time when sys.buffalloc executes).
//<br><br>
//The maximum number of pages you can request for this buffer is limited to 255.
//--------------------------------------------------------------------
Object.defineProperty(bt, 'rxbuffsize', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD | DWORD), DEFAULT VALUE=0 (0 bytes). </b><br><br>
//Returns the current capacity, in bytes, of the BLE's RX buffer.  
//To change the buffer capacity, use the bt.rxbuffrq method followed by the sys.buffalloc method.
//<br><br>
//Bt.rxbuffrq requests buffer allocation in 256-byte pages whereas this property returns the buffer size in bytes.
//Relationship between the two is as follows: bt.rxbuffsize = num_pages * 256 - 33 (or =0 when num_pages=0), where
//"num_pages" is the number of buffer pages that was GRANTED through bt.rxbuffrq.
//"-33" is because a number of bytes is needed for internal buffer variables.
//<br><br>
//The BLE interface is unable to receive data when its RX buffer has zero capacity.
//--------------------------------------------------------------------
Object.defineProperty(bt, 'txbuffsize', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD | DWORD), DEFAULT VALUE=0 (0 bytes). </b><br><br>
//Returns the current capacity, in bytes, of the BLE's TX buffer.  
//To change the buffer capacity, use the bt.txbuffrq method followed by the sys.buffalloc method.
//<br><br>
//Bt.txbuffrq requests buffer allocation in 256-byte pages whereas this property returns the buffer size in bytes.
//Relationship between the two is as follows: bt.txbuffsize = num_pages * 256 - 33 (or =0 when num_pages=0), where
//"num_pages" is the number of buffer pages that was GRANTED through bt.txbuffrq.
//"-33" is because a number of bytes is needed for internal buffer variables.
//<br><br>
//The BLE interface is unable to transmit data when its TX buffer has zero capacity.
//--------------------------------------------------------------------
Object.defineProperty(bt, 'rxlen', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD | DWORD), DEFAULT VALUE=0 (0 bytes). </b><br><br>
//Returns the total number of bytes currently waiting in the RX buffer of the BLE interface.
//--------------------------------------------------------------------
Object.defineProperty(bt, 'txlen', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD | DWORD), DEFAULT VALUE=0 (0 bytes). </b><br><br>
//Returns the total number of committed bytes in the TX buffer of the BLE interface.
//--------------------------------------------------------------------
Object.defineProperty(bt, 'txfree', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD | DWORD), DEFAULT VALUE=0 (0 bytes). </b><br><br>
//Returns the amount of free space, in bytes, in the TX buffer of the BLE interface, not taking into the account uncommitted data.
//<br><br>
//The actual free space in the buffer is bt.txfree - bt.newtxlen. Your application will not be able to store more data than this amount.
//--------------------------------------------------------------------
Object.defineProperty(bt, 'newtxlen', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (WORD | DWORD), DEFAULT VALUE=0 (0 bytes). </b><br><br>
//Returns the total number of uncommitted bytes in the TX buffer of the BLE interface.
//<br><br>
//Uncommited data is data that was added to the TX buffer using bt.setdata but hasn't been committed using bt.send.
//--------------------------------------------------------------------
bt.rxclear = function () { };
//<b>METHOD. </b><br><br>
//Clears the RX buffer of the BLE interface.
//--------------------------------------------------------------------
bt.txclear = function () { };
//<b>METHOD. </b><br><br>
//Clears the TX buffer of the BLE interface.
//--------------------------------------------------------------------
bt.getdata = function (maxinplen) { };
//<b>METHOD. </b><br><br>
//Returns the string containing the data extracted from the RX buffer of the BLE interface. Extracted data is removed from the buffer.
//<br><br>
//The length of extracted data is limited by one of the three factors, whichever is smaller: the amount of data in the RX buffer itself,
//capacity of the receiving string variable, and the limit set by the maxinplen argument.
//--------------------------------------------------------------------
bt.peekdata = function (maxinplen) { };
//<b>METHOD.</b><br><br>
//Returns the string containing the "preview" of data from the RX buffer of the BLE interface. The data is NOT removed from the buffer.
//<br><br>
//The length of returned data is limited by one of the three factors, whichever is smaller: the amount of data in the RX buffer itself, capacity of the receiving string variable,
//and the limit set by the maxinplen argument.
//<br><br>
//Since string variables can hold up to 255 bytes of data, this method will only allow you to preview up to this number of bytes.
//--------------------------------------------------------------------
bt.setdata = function (txdata) { };
//<b>METHOD. </b><br><br>
//Stores the data passed in the txdata argument into the TX buffer of the BLE inteface.
//<br><br>
//If the buffer doesn't have enough space to accommodate the data being added then this data will be truncated.
//<br><br>
//The newly stored data is not sent out immediately. This only happens after the bt.send method is used to commit this data.
//This allows your application to prepare large amounts of data before sending it out.
//--------------------------------------------------------------------
bt.send = function () { };
//<b>METHOD. </b><br><br>
//Commits (allows sending out) the data that was previously saved into the TX buffer of the BLE interface using the bt.setdata method.
//--------------------------------------------------------------------
bt.notifysent = function (threshold) { };
//<b>METHOD. </b><br><br>
//Invoking this method will cause the on_bt_data_sent event to be generated when the amount of committed data in the TX buffer of the BLE interface drops to or below
//the "threshold" number of bytes.
//<br><br>
//This method, together with on_bt_data_sent provides a way to handle data sending asynchronously.
//<br><br>
//Only one on_bt_data_sent event will be generated each time after bt.notifysent is invoked.
//--------------------------------------------------------------------
Object.defineProperty(bt, 'advertise', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE= <font color="olive"><b>0- NO</b></font></b><br><br>
//Setting this property to 1 -YES will start the advertising service on the BLE interface. Setting the property to 0- NO halts BLE advertising.
//<br><br>
//The value of this property can only be set to 1- YES when the BLE interface is enabled (bt.enabled= 1- YES, i.e. bt.enable was previously called).
//<br><br>
//The value of this property is reset to 0- NO if the BLE interface becomes disabled (bt.enabled= 0- NO) for any reason.
//--------------------------------------------------------------------
//<b>PLATFORM CONSTANT.</b><br><br>The BLE interface has accepted an incoming connection.
//<b>PLATFORM CONSTANT.</b><br><br>The BLE interface is no longer engaged in a connection.
//<b>PLATFORM CONSTANT.</b><br><br>The BLE interface has been enabled.
//<b>PLATFORM CONSTANT.</b><br><br>The BLE interface has been disabled.
//<b>EVENT of the bt object. </b><br><br>
//Generated when the following BLE events occur:
//<br><br>
//0- _CONNECTED -- The BLE interface has accepted an incoming connection.
//<br><br>
//1- _DISCONNECTED -- The BLE interface is no longer engaged in a connection.
//<br><br>
//2- _ENABLED -- The BLE interface has been enabled (through bt.enable).
//<br><br>
//3- _DISABLED -- The BLE interface has been disabled (through bt.disable).
//--------------------------------------------------------------------
//<b>EVENT of the bt object. </b><br><br> 
//Generated as soon as the BLE interface receives data into the RX buffer.
//<br><br>
//There may be only one on_bt_data_arrival event in the event queue.
//Another on_bt_data_arrival event will be generated only after the previous one is handled.
//<br><br>
//If, during the on_bt_data_arrival event handler execution, not all data is extracted from the RX 
//buffer, another on_bt_data_arrival event is generated immediately after the 
//on_bt_data_arrival event handler is exited.
//--------------------------------------------------------------------
//<b>EVENT of the bt object. </b><br><br> 
//Generated after the total amount of committed data in the TX buffer of the BLE interface drops to or below the threshold that was preset through the bt.notifysent method.
//<br><br>
//This event, together with bt.notifysent provides a way to handle data sending asynchronously.
//<br><br>
//Only one on_bt_data_sent event will be generated each time after bt.notifysent is invoked.
//--------------------------------------------------------------------
//<b>EVENT of the bt object. </b><br><br>
//Generated when the RX buffer of the BLE interface overflows.
//<br><br>
//An overrun may happen if the BLE interface is receiving data faster than the speed at which your app is extracting and processing it.
//--------------------------------------------------------------------
Object.defineProperty(bt, 'connected', {
    get() { return 0; },
    set() { }
});
//<b>R/O PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0- NO.</b><br><br>
//Indicates whether the BLE interface is engaged in a connection.
//--------------------------------------------------------------------
Object.defineProperty(bt, 'mac', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY(STRING), DEFAULT VALUE= "0.0.0.0.0.0". </b><br><br>
//Sets and returns the MAC address of the BLE interface.
//<br><br>
//Each WA2000 device comes with its own unique hardcoded Bluetooth MAC. You can use this MAC or set another MAC programmatically.
//<br><br>
//If you do not write to this property, bt.mac returns 0.0.0.0.0.0 before executing wln.boot.
//The property returns the hardcoded MAC address of the WA2000 after wln.boot is called (and wln.enabled becomes 1- YES).
//<br><br>
//To set a different Bluetooth MAC, assign a new value to this property before calling wln.boot.
//The value of the property cannot be changed after the wln.boot method has been invoked.
//--------------------------------------------------------------------
//--------------------------------------------------------------------
//--------------------------------------------------------------------
//property bt.num
//<b>PROPERTY (BYTE), DEFAULT VALUE= 0 (bt channel selected). </b><br><br>
//Sets/returns the number of currently selected bt channel (channels are enumerated from 0).
//Most other properties and methods of this object relate to the bt channel selected through this property.<br><br>
//Note that bt channel related events such as <font color="teal"><b>on_bt_data_arrival </b></font> change currently selected port!
//The value of this property won't exceed <font color="maroon"><b>bt.numofchannels</b></font>-1 (even if you attempt to set a higher value).
//    get = syscall(798) as byte
//    set = syscall(799) (value as byte)
//end property
//<b>ENUM. </b><br><br> 
//Contains the list of constants related to the flow control for the bluetooth object.
//<b>PLATFORM CONSTANT (DEFAULT). </b><br><br> 
//No flow control, the on_bt_overrun event will be received.
//<b>PLATFORM CONSTANT. </b><br><br> 
//Flow control enabled. When receiving data via reliable writes the data will no longer be accepted once all bluetooth buffers are full. 
Object.defineProperty(bt, 'flowcontrol', {
    get() { return 0; },
    set() { }
});
//<b>PROPERTY (ENUM, BYTE), DEFAULT VALUE= 0- DISABLED. </b><br><br> 
//Sets/returns flow control mode for bluetooth object. When enabled this property will stop receiving data from the bluetooth link when its RX buffer is full. It is only relevant when the application that is sending data to the device is using reliable writes. When this property is enabled it is not possible to receive the on_bt_overrun event. 
//# sourceMappingURL=tios.js.map