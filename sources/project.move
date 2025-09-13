module MyModule::LanguageLearning {
    use aptos_framework::signer;
    use aptos_framework::coin;
    use aptos_framework::aptos_coin::AptosCoin;
    
    /// Struct representing a learner's progress and rewards.
    struct LearnerProfile has store, key {
        lessons_completed: u64,    // Number of lessons completed
        total_rewards: u64,        // Total reward tokens earned
        reward_rate: u64,          // Tokens earned per lesson (default: 10)
    }
    
    /// Error codes
    const E_PROFILE_NOT_EXISTS: u64 = 1;
    const E_INSUFFICIENT_BALANCE: u64 = 2;
    
    /// Function to initialize a learner profile with default settings.
    public fun initialize_learner(learner: &signer) {
        let profile = LearnerProfile {
            lessons_completed: 0,
            total_rewards: 0,
            reward_rate: 10, // Default 10 tokens per lesson
        };
        move_to(learner, profile);
    }
    
    /// Function to complete a lesson and receive reward tokens.
    public fun complete_lesson(
        learner: &signer, 
        reward_pool: &signer
    ) acquires LearnerProfile {
        let learner_addr = signer::address_of(learner);
        let profile = borrow_global_mut<LearnerProfile>(learner_addr);
        
        // Update lesson progress
        profile.lessons_completed = profile.lessons_completed + 1;
        
        // Calculate and distribute rewards
        let reward_amount = profile.reward_rate;
        profile.total_rewards = profile.total_rewards + reward_amount;
        
        // Transfer reward tokens from pool to learner
        let reward_coins = coin::withdraw<AptosCoin>(reward_pool, reward_amount);
        coin::deposit<AptosCoin>(learner_addr, reward_coins);
    }
}