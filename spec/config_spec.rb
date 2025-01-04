RSpec.describe "Zxcvbn::Config" do
  describe "#add_dictionary" do
    let(:dictionary_path) { 'custom_dictionary.txt' }
    let(:dictionary_contents) { "password_1\npassword_2\npassword_3" }

    before do
      allow(File).to receive(:read).with(dictionary_path).and_return(dictionary_contents)
    end

    it "adds a custom dictionary to RANKED_DICTIONARIES" do
      Zxcvbn.config.add_dictionary(dictionary_path)

      expected_dictionary = {
        'custom_dictionary' => {
          'password_1' => 1,
          'password_2' => 2,
          'password_3' => 3
        }
      }

      expect(Zxcvbn::Matching::RANKED_DICTIONARIES).to include(expected_dictionary)
    end
  end

  describe ".configure" do

    context "when called with a block" do
      it "yields the Config module" do
        expect { |b| Zxcvbn.configure(&b) }.to yield_with_args(Zxcvbn::Config)
      end
    end

    context "when called without a block" do
      it "returns the Config module" do
        expect(Zxcvbn.configure).to eq(Zxcvbn.config)
      end
    end
  end

  describe ".config" do
    it "returns the Config module" do
      expect(Zxcvbn.config).to eq(Zxcvbn.config)
    end
  end
end
