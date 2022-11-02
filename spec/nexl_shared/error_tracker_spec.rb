module NexlShared
  RSpec.describe ErrorTracker, type: :model do
    describe ".error" do
      it 'works' do
        described_class.error("Error!")
      end
    end

    describe ".warn" do
      it 'works' do
        described_class.warn("Warn!")
      end
    end

    describe ".info" do
      it 'works' do
        described_class.info("Info!")
      end
    end
  end
end

