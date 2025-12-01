import { Hero } from "@/components/landing/es/Hero";
import { Quiz } from "@/components/landing/es/Quiz";
import { CountdownTimer } from "@/components/landing/es/CountdownTimer";
import { Features } from "@/components/landing/es/Features";
import { ServicesHighlight } from "@/components/landing/es/ServicesHighlight";
import { Pricing } from "@/components/landing/es/Pricing";
import { SavingsCalculator } from "@/components/landing/es/SavingsCalculator";
import { PackageComparison } from "@/components/landing/es/PackageComparison";
import { Testimonials } from "@/components/landing/es/Testimonials";
import { TrustSection } from "@/components/landing/es/TrustSection";
import { FAQ } from "@/components/landing/es/FAQ";
import { FinalCTA } from "@/components/landing/es/FinalCTA";
import { ExitIntentPopup } from "@/components/landing/ExitIntentPopup";
import { FloatingChat } from "@/components/FloatingChat";

const LandingES = () => {
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

export default LandingES;
