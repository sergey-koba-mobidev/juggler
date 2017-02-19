defmodule Juggler.Project.Operations.CheckBranch do
  import Monad.Result, only: [success?: 1,
                              unwrap!: 1,
                              success: 1,
                              error: 1]

  def call(project, branch) do
    result = false
    if project.branches != nil do
      branches_arr = String.split(project.branches, "\r\n")
      result = check_branches(branches_arr, String.replace(branch, "refs/heads/", ""))
    end

    if result do
      success(nil)
    else
      error(nil)
    end
  end

  def check_branches(branches, branch) do
    case List.pop_at(branches, 0) do
      {nil, []} ->
        false
      {pattern, branches} ->
        case check_branch(pattern, branch) do
          true  -> true
          false -> check_branches(branches, branch)
        end
    end
  end

  def check_branch(pattern, branch) do
    case Regex.compile("^" <> pattern <> "$") do
      {:ok, r} -> Regex.match?(r, branch)
      _ -> false
    end
  end
end
