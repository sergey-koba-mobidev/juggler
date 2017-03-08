// NOTE: The contents of this file will only be executed if
// you uncomment its entry in "web/static/js/app.js".

// To use Phoenix channels, the first step is to import Socket
// and connect at the socket path in "lib/my_app/endpoint.ex":
import {Socket} from "phoenix"
import $ from "jquery"

let socket = new Socket("/socket", {params: {token: window.userToken}})

// When you connect, you'll often need to authenticate the client.
// For example, imagine you have an authentication plug, `MyAuth`,
// which authenticates the session and assigns a `:current_user`.
// If the current user exists you can assign the user's token in
// the connection for use in the layout.
//
// In your "web/router.ex":
//
//     pipeline :browser do
//       ...
//       plug MyAuth
//       plug :put_user_token
//     end
//
//     defp put_user_token(conn, _) do
//       if current_user = conn.assigns[:current_user] do
//         token = Phoenix.Token.sign(conn, "user socket", current_user.id)
//         assign(conn, :user_token, token)
//       else
//         conn
//       end
//     end
//
// Now you need to pass this token to JavaScript. You can do so
// inside a script tag in "web/templates/layout/app.html.eex":
//
//     <script>window.userToken = "<%= assigns[:user_token] %>";</script>
//
// You will need to verify the user token in the "connect/2" function
// in "web/channels/user_socket.ex":
//
//     def connect(%{"token" => token}, socket) do
//       # max_age: 1209600 is equivalent to two weeks in seconds
//       case Phoenix.Token.verify(socket, "user socket", token, max_age: 1209600) do
//         {:ok, user_id} ->
//           {:ok, assign(socket, :user, user_id)}
//         {:error, reason} ->
//           :error
//       end
//     end
//
// Finally, pass the token on connect as below. Or remove it
// from connect if you don't care about authentication.

socket.connect()

// Now that you are connected, you can join channels with a topic:
let outputCont = $('#output')
let buildId = window.buildId
let deployId = window.deployId

if (buildId !== undefined || deployId !== undefined) {
  let channelName = (buildId !== undefined) ? ("build:" + buildId) : ("deploy:" + deployId)
  let channel = socket.channel(channelName, {})

  channel.join()
    .receive("ok", resp => { console.log("Joined successfully", resp) })
    .receive("error", resp => { console.log("Unable to join", resp) })

  var addMessageToOutput = (msg, append) => {
    if (append || append == null) {
      outputCont.append(msg)
    } else {
      outputCont.prepend(msg)
    }
  }

  var cmdStart = (payload, append = true) => {
    console.log("cmd_start", payload)
    addMessageToOutput("<div class='ui small compact message'>Started <b>" + payload.cmd + "</b> command</div> \n", append)
  }
  var cmdData = (payload, append = true) => {
    console.log("cmd_data", payload, append)
    addMessageToOutput(payload.output, append)
  }
  var cmdResult = (payload, append = true) => {
    console.log("cmd_result", payload)
    addMessageToOutput("<div class='ui small "+(payload.status == '0' ? 'positive' : 'negative')+" compact message'>Finished <b>" + payload.cmd + "</b>, result code: " + payload.status + " </div>\n", append)
  }
  var cmdFinished = (payload, append = true) => {
    console.log("cmd_finished", payload)
    addMessageToOutput("<div class='ui small positive compact message'>Finished</div>", append)
    if ($("#stop-button").length) {
      $("#stop-button").hide()
    }
    $("#deploy-build").show()
  }
  var cmdFinishedError = (payload, append = true) => {
    console.log("cmd_finished_error", payload)
    addMessageToOutput("<div class='ui small negative compact message'>Finished with error: " + payload.error_msg + "</div>", append)
    if ($("#stop-button").length) {
      $("#stop-button").hide()
    }
    $("#restart-button").show()
  }

  var cmdNewState = (payload) => {
    $(".card .content .header i").replaceWith(payload.html)
    if (payload.state == "running") {
      $("#stop-button").show()
    } else {
      $("#stop-button").hide()
    }
  }

  channel.on("cmd_start", cmdStart)
  channel.on("cmd_data", cmdData)
  channel.on("cmd_result", cmdResult)
  channel.on("cmd_finished", cmdFinished)
  channel.on("cmd_finished_error", cmdFinishedError)
  channel.on("new_deploy_state", cmdNewState)
  channel.on("new_build_state", cmdNewState)

  channel.on("cmd_old", ({outputs}) => {
    console.log("cmd_old", outputs)
    outputs.forEach( output => {
      switch (output.event) {
        case "cmd_start":
          cmdStart(output.payload, false)
          break;
        case "cmd_data":
          cmdData(output.payload, false)
          break;
        case "cmd_result":
          cmdResult(output.payload, false)
          break;
        case "cmd_finished":
          cmdFinished(output.payload, false)
          break;
        case "cmd_finished_error":
          cmdFinishedError(output.payload, false)
          break;
      }
    })
  })
}
export default socket
