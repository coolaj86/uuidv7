import UUIDv7 from "./uuidv7.js";

{
  let uuidv7 = UUIDv7.uuidv7();
  console.info(uuidv7);
}

{
  let uuidv7 = UUIDv7.uuidv7();
  console.info(uuidv7);
}

{
  let uuidv7 = UUIDv7.uuidv7();
  console.info(uuidv7);
}

let bytes4k = new Uint8Array(4096);
UUIDv7.setBytesBuffer(bytes4k);

{
  let uuidv7 = UUIDv7.uuidv7();
  console.info(uuidv7);
}

{
  let uuidv7 = UUIDv7.uuidv7Bytes();
  console.info(UUIDv7._cursor, uuidv7);
}

{
  let uuidv7 = UUIDv7.uuidv7Bytes();
  console.info(UUIDv7._cursor, uuidv7);
}

{
  let uuidv7 = UUIDv7.uuidv7Bytes();
  console.info(UUIDv7._cursor, uuidv7);
}

{
  let uuidv7 = UUIDv7.uuidv7();
  console.info(uuidv7);
}
