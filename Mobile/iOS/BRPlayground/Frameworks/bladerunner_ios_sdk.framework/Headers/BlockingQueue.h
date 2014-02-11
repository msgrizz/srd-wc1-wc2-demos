//
//  BlockingQueue.h
//  bladerunner_ios_sdk
//
//  Created by Evgeniy Kapralov on 7/16/13.
//  Copyright (c) 2013 Plantronics. All rights reserved.
//

#ifndef __bladerunner_ios_sdk__BlockingQueue__
#define __bladerunner_ios_sdk__BlockingQueue__

#include <mutex>
#include <condition_variable>
#include <deque>

namespace bladerunner
{
    template <typename T>
    class BlockingQueue
    {

    public:
        void push(T const& value)
        {
            {
                std::unique_lock<std::mutex> lock(mLock);
                mQueue.push_front(value);
            }
            mCondition.notify_one();
        }

        T pop()
        {
            std::unique_lock<std::mutex> lock(mLock);
            mCondition.wait(lock, [=]{ return !mQueue.empty(); });
            T rc(std::move(mQueue.back()));
            mQueue.pop_back();
            
            return rc;
        }

        bool empty()
        {
            std::unique_lock<std::mutex> lock(mLock);
            return mQueue.empty();
        }

        void clear()
        {
            std::unique_lock<std::mutex> lock(mLock);
            mQueue.clear();
        }


    private:
        std::mutex mLock;
        std::condition_variable mCondition;
        std::deque<T> mQueue;
    };
}

#endif /* defined(__bladerunner_ios_sdk__BlockingQueue__) */
