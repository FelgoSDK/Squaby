var queue = [];

function take() {
  return queue.shift();
}

function push(item) {
  return queue.push(item);
}

function size() {
  return queue.length;
}
