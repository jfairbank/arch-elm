function fetchUser(id) {
  const url = `/user/${id}`;
  return axios.get(url);
}
