import { Hero } from "@/components/landing/Hero";
import { Quiz } from "@/components/landing/Quiz";
import { CountdownTimer } from "@/components/landing/CountdownTimer";
import { Features } from "@/components/landing/Features";
import { ServicesHighlight } from "@/components/landing/ServicesHighlight";
import { Pricing } from "@/components/landing/Pricing";
import { SavingsCalculator } from "@/components/landing/SavingsCalculator";
import { PackageComparison } from "@/components/landing/PackageComparison";
import { Testimonials } from "@/components/landing/Testimonials";
import { TrustSection } from "@/components/landing/TrustSection";
import { FAQ } from "@/components/landing/FAQ";
import { FinalCTA } from "@/components/landing/FinalCTA";
import { ExitIntentPopup } from "@/components/landing/ExitIntentPopup";

const Index = () => {
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
    </div>
  );
};

export default Index;
