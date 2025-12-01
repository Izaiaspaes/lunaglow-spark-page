import { Hero } from "@/components/landing/en/Hero";
import { Quiz } from "@/components/landing/en/Quiz";
import { CountdownTimer } from "@/components/landing/en/CountdownTimer";
import { Features } from "@/components/landing/en/Features";
import { ServicesHighlight } from "@/components/landing/en/ServicesHighlight";
import { Pricing } from "@/components/landing/en/Pricing";
import { SavingsCalculator } from "@/components/landing/en/SavingsCalculator";
import { PackageComparison } from "@/components/landing/en/PackageComparison";
import { Testimonials } from "@/components/landing/en/Testimonials";
import { TrustSection } from "@/components/landing/en/TrustSection";
import { FAQ } from "@/components/landing/en/FAQ";
import { FinalCTA } from "@/components/landing/en/FinalCTA";
import { ExitIntentPopup } from "@/components/landing/ExitIntentPopup";
import { FloatingChat } from "@/components/FloatingChat";

const LandingEN = () => {
  return (
    <div className="min-h-screen">
      <Hero />
      <Quiz />
      <CountdownTimer />
      <Features />
      <ServicesHighlight />
      <Pricing />
      <SavingsCalculator />
      <PackageComparison />
      <Testimonials />
      <TrustSection />
      <FAQ />
      <FinalCTA />
      <ExitIntentPopup />
      <FloatingChat />
    </div>
  );
};

export default LandingEN;
