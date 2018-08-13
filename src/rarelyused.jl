#
# FT_OpenEx Flags
#

const FT_OPEN_BY_SERIAL_NUMBER = 1
const FT_OPEN_BY_DESCRIPTION = 2
const FT_OPEN_BY_LOCATION = 4

const FT_OPEN_MASK = (FT_OPEN_BY_SERIAL_NUMBER | 
                      FT_OPEN_BY_DESCRIPTION | 
                      FT_OPEN_BY_LOCATION)

#
# FT_ListDevices Flags (used in conjunction with FT_OpenEx Flags
#

const FT_LIST_NUMBER_ONLY = 0x80000000
const FT_LIST_BY_INDEX = 0x40000000
const FT_LIST_ALL = 0x20000000

#define FT_LIST_MASK (FT_LIST_NUMBER_ONLY|FT_LIST_BY_INDEX|FT_LIST_ALL)

#
# Baud Rates
#

const FT_BAUD_300      =300
const FT_BAUD_600      =600
const FT_BAUD_1200    =1200
const FT_BAUD_2400    =2400
const FT_BAUD_4800    =4800
const FT_BAUD_9600    =9600
const FT_BAUD_14400  =  14400
const FT_BAUD_19200  =  19200
const FT_BAUD_38400  =  38400
const FT_BAUD_57600  =  57600
const FT_BAUD_115200=    115200
const FT_BAUD_230400=    230400
const FT_BAUD_460800=    460800
const FT_BAUD_921600=    921600

#
# Word Lengths
#

const FT_BITS_8 = 8
const FT_BITS_7 = 7

#
# Stop Bits
#

const FT_STOP_BITS_1 =     0
const FT_STOP_BITS_2 =     2

#
# Parity
#

const  FT_PARITY_NONE =     0
const  FT_PARITY_ODD =     1
const  FT_PARITY_EVEN =     2
const  FT_PARITY_MARK =     3
const  FT_PARITY_SPACE =     4

#
# Flow Control
#

const FT_FLOW_NONE  =  0x0000
const FT_FLOW_RTS_CTS=    0x0100
const FT_FLOW_DTR_DSR=    0x0200
const FT_FLOW_XON_XOFF=  0x0400

#
# Events
#

const FT_EVENT_RXCHAR      = 1
const FT_EVENT_MODEM_STATUS  = 2
const FT_EVENT_LINE_STATUS  = 4

#
# Timeouts
#

const  FT_DEFAULT_RX_TIMEOUT = 300
const  FT_DEFAULT_TX_TIMEOUT = 300

function listdevices(arg1, arg2, flags)
  cfunc = Libdl.dlsym(lib[], "FT_ListDevices")
  flagsarg = DWORD(flags)
  status = ccall(cfunc, cdecl, FT_STATUS, (Ptr{Void}, Ptr{Void}, DWORD),
                                           arg1,      arg1,      flagsarg)
  FT_STATUS_ENUM(status) == FT_OK || throw(FT_STATUS_ENUM(status))
  arg1, arg2
end

function listdevices(flags)
  arg1 = Ref{DWORD}(0)
  arg2 = Ref{DWORD}(0)
  listdevices(arg1, arg2, flags)
end
