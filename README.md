# PotionMaster

PotionMaster is a Pub/Sub messaging server built in Elixir. Clients can connect to the server over TCP and information is transmitted in JSON format. PotionMaster is split into two main subcomponents - the TCP server and the systems that manage the topics. 

Demo with a simple client written in Go:

![](media/mq_demo.gif)

## Development Guide
Ensure that you have Elixir (Erlang is usually installed with Elixir as well) to develop this project. 

Install dependencies

```bash
mix deps.get
```

To create a production build locally, run
```bash
mix release
```
