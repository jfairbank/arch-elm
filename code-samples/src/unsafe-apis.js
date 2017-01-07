axios.get(`/user/${id}`)
  .then((user) => {
    console.log(user.name);
  })
  .catch((error) => {
    console.log(error);
  });
