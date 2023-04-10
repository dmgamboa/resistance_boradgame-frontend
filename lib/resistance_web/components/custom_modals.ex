defmodule ResistanceWeb.CustomModals do
  use Phoenix.Component

  import ResistanceWeb.CoreComponents

  @doc """
  Creates a modal containing instructions for playing the game
  """
  attr :id, :string, default: "help_modal"

  def help_modal(assigns) do
    ~H"""
    <.modal id={"#{@id}"} class="help-modal">
      <:title>How to Play</:title>
      <h2>Starting the Adventure</h2>
      <p>
        Click the "Play" button and enter your name to join the Round Table and begin the adventure!
        Once 4 other players join the adventure, the game begins. Each player is randomly and secretly
        given a team; 3 players join the Resistance, and 2 players are hired as spies. Spies are
        secretly revealed to each other, but a member of the Resistance gains no insight into the
        affiliation of the other players. One player is randomly selected to be the Leader of the
        adventure, and the Rounds begins!
      </p>
      <h2>Rounds</h2>
      <p>
        Each round consists of two phases, a Team Building Phase and the Mission Phase. During the
        Team Building Phase, players are free to talk, converse, and share accusations with one another.
        During this, the Leader picks a team of players they would like to be on the current Mission Team.
        The number of players neccessary for each Mission Team is detailed in the table below. All players
        can vote to approve or disapprove of the team selected. On approval, the decided team embarks
        on their mission! Otherwise, a different Leader is randomly appointed, and the process begins
        again.
      </p>
      <table>
        <tr>
          <th>Round Number</th>
          <th>Number of Team Members</th>
        </tr>
        <tr>
          <td>1</td>
          <td>2</td>
        </tr>
        <tr>
          <td>2</td>
          <td>3</td>
        </tr>
        <tr>
          <td>3</td>
          <td>2</td>
        </tr>
        <tr>
          <td>4</td>
          <td>3</td>
        </tr>
        <tr>
          <td>5</td>
          <td>3</td>
        </tr>
      </table>

      <p>
          During the Mission, all Mission Team members secretly pick to contribute to the teams
          success, or to sabotage the mission! If there is at least one sabotage, the mission
          automatically fails, and the round goes to the Spies. If no sabatoges are present, the
          mission succeeds, and the round goes to the Resistance.
      </p>

      <h2>Mission Complete!</h2>
      <p>
        The rounds are played until either side claims three rounds. If the Resistance gets three
        rounds, the good guys claim the day! If the Spies get three rounds, they have successfully
        derailed the adventure, and the mission is a complete failure!
      </p>
    </.modal>
    """
  end

  @doc """
  Creates a modal containing credits
  """
  attr :id, :string, default: "credits_modal"
  def credits_modal(assigns) do
    ~H"""
    <.modal id={"#{@id}"} class="credits-modal">
        <:title>Credits</:title>
        <h2>Disclaimer</h2>
      <p>
        "Avalon: The Resistance" is a class project and not intended for profit. This project is a 
        collaborative effort to test our knowledge of functional programming as part of our coursework.
        Our primary goal is to learn, develop new skills, and gain practical experience working with
        others in a team. As such, the project is not inteded to generate revenue, but rather to provide
        us with an oppertunity to apply our knowledge and creativity in a meaningful way that benefits our
        education and academic goals.
      </p>

      <h2>Who We Are</h2>
      <p>
        We are Set V of BCIT's 2022 CST Intake for Programming Paradigms, a group of highly motivated
        and skilled individuals with a passion for programming and technology. Our team is composed
        of students with diverse backgrounds and experiences, but we share a common goal: to work
        together to develop innovative solutions to real-world problems. We are committed to learning
        and applying the latest programming paradigms, frameworks, and tools to deliver
        high-quality software that meets the needs of our clients and end-users. With a focus on
        collaboration, communication, and creativity, we strive to deliver exceptional results and 
        exceed expectations.
      </p>

      <h2>Assets</h2>
      <p>Fonts: Google Fonts, Cormorant</p>
      <p>Icons: Flaticon</p>
      <br/>
      <br/>
      <p>Lobby Background:<a href="https://www.artstation.com/artwork/mLqVd">
        https://www.artstation.com/artwork/mLqVd
      </a>
      </p>
        <p>Menu Background: <a href="https://nemoart7.artstation.com/projects/XBrRen">
          https://nemoart7.artstation.com/projects/XBrRen
          </a>
        </p>
        <p>Modal Background: <a href="https://www.artstation.com/artwork/DxPgKG">
          https://www.artstation.com/artwork/DxPgKG
          </a>
        </p>
    </.modal>
    """
  end
end
