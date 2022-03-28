const fetchData = async () => {
  const res = await fetch("https://v0l86rl87i.execute-api.eu-west-2.amazonaws.com/pass-counter-stage/read?viewcount=0")
  const data = await res.json()

  return data.views
}

const postData = async (views) => {
  await fetch("https://v0l86rl87i.execute-api.eu-west-2.amazonaws.com/pass-counter-stage/write", {
    method: "POST",
    body: JSON.stringify({views}),
    headers: { "Content-Type": "application/json"}
  }
  )
}

const displayCount = (views) => {
  const counter = document.getElementById("counter")

  counter.textContent = views
    
}

const init = async () => {

  const views = await fetchData()

  const x = Number(views) + 1

  const updatedViews = String(x)

  postData(updatedViews)

  displayCount(updatedViews)
}

init()