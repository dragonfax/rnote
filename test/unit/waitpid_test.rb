
require 'rnote/edit'
require 'minitest/autorun'

describe WaitPidTimeout do
  
  it 'should time at least once with a slow child' do
    
    pid = fork {
      sleep 3
    }
    
    waitpt = WaitPidTimeout.new(pid,1)
    
    done = false
    timeout = 0
    while not done 
      if waitpt.wait
        done = true
      else
        timeout += 1
      end
    end
    
    assert timeout > 0
    
    
  end
  
  it 'should not time out at all with a fast child' do
    pid = fork {
      sleep 0.5
    }
    
    waitpt = WaitPidTimeout.new(pid,1)
    
    done = false
    timeout = 0
    while not done 
      if waitpt.wait
        done = true
      else
        timeout += 1
      end
    end
    
    assert_equal 0, timeout
  end
   
  it 'should not time out at all with a finished child' do
    
    pid = fork {
    }
    
    sleep 0.5 # give it time to finihs. how else can I 
    
    waitpt = WaitPidTimeout.new(pid,1)
    
    done = false
    timeout = 0
    while not done 
      if waitpt.wait
        done = true
      else
        timeout += 1
      end
    end
    
    assert_equal 0, timeout
  end
   
end


