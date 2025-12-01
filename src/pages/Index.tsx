import { Hero } from "@/components/landing/Hero";
import { Features } from "@/components/landing/Features";
import { ServicesHighlight } from "@/components/landing/ServicesHighlight";
import { PlanCalculator } from "@/components/landing/PlanCalculator";
import { Pricing } from "@/components/landing/Pricing";
import { Testimonials } from "@/components/landing/Testimonials";
import { FAQ } from "@/components/landing/FAQ";
import { FinalCTA } from "@/components/landing/FinalCTA";

const Index = () => {
  return (
    <div className="min-h-screen">
      <Hero />
      <Features />
      <ServicesHighlight />
      <PlanCalculator />
      <Testimonials />
      <Pricing />
      <FAQ />
      <FinalCTA />
    </div>
  );
};

export default Index;
