function mayThrow() {
  throw new Error('Whoops...')
}

function unsafe() {
  try {
    mayThrow();
  } catch (e) {
    handleError(e);
  }
}
