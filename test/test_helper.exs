Application.load(:xfp_app)

for app <- Application.spec(:xfp_app,:applications) do
  Application.ensure_all_started(app)
end

ExUnit.start()
