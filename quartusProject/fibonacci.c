const u8 MAX = 24;
const u8 SWITCHES_ADDRESS = 65535;

int main(void) {
  u8[] memory;
  u8 offset;
  u8 v;

  for (int i = 0; i <= MAX; i++) {
    memory[i] = fibonacci(memory, i);
  }

  while (true) {
    offset = memory[SWITCHES_ADDRESS];
    v = memory[offset];
    memory[SWITCHES_ADDRESS] = v;
  }
}

int fibonacci(u16* fs, u16 i) {
  if (i == 0) {
    return 0;
  } else if (i == 1) {
    return 1;
  } else {
    return fs[n - 1] + fs[n - 2];
  }
}
