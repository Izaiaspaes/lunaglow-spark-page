import { Hero } from "@/components/landing/Hero";
import { Quiz } from "@/components/landing/Quiz";
import { Features } from "@/components/landing/Features";
import { ServicesHighlight } from "@/components/landing/ServicesHighlight";
import { PlanCalculator } from "@/components/landing/PlanCalculator";
import { Pricing } from "@/components/landing/Pricing";
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
      <Features />
      <ServicesHighlight />
      <PlanCalculator />
      <Testimonials />
      <Pricing />
      <TrustSection />
      <FAQ />
      <FinalCTA />
      <ExitIntentPopup />
    </div>
  );
};

export default Index;
