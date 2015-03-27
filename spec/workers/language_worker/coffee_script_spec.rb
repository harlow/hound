require "rails_helper"

describe LanguageWorker::CoffeeScript do
  it_behaves_like "Language not moved to IronWorker" do
    let(:content) { "1" * 81 }
    let(:messages) { ["Line exceeds maximum allowed length"] }
    let(:language) { "coffee_script" }
  end
end