-- Mon 01:26 Aug 15

local weblit = require('weblit')

weblit.app
  .bind({host = "127.0.0.1", port = 1337})

  -- Configure weblit server
  .use(weblit.logger)
  .use(weblit.autoHeaders)

  -- A custom route that sends back method and part of url.
  .route({ path = "/:name"}, function (req, res)
    res.body = req.method .. " - " .. req.params.name .. "\n"
    res.code = 200
    res.headers["Content-Type"] = "text/plain"
  end)

  -- Start the server
  .start()
